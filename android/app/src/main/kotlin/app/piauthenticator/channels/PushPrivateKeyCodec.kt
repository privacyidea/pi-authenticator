// SPDX-License-Identifier: Apache-2.0

package app.piauthenticator.channels

import java.math.BigInteger
import java.security.GeneralSecurityException
import java.security.InvalidKeyException
import java.security.KeyFactory
import java.security.PrivateKey
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.RSAPrivateCrtKeySpec

/** Decodes standards-compliant PKCS#1 RSA keys and a validated legacy encoding. */
internal object PushPrivateKeyCodec {
    private val RSA_PUBLIC_EXPONENT = BigInteger.valueOf(65537L)
    private val ONE = BigInteger.ONE
    private val ZERO = BigInteger.ZERO

    internal data class DecodedKey(
        val privateKey: PrivateKey,
        val repairedLegacyEncoding: Boolean,
    )

    private data class RsaComponents(
        val version: BigInteger,
        val modulus: BigInteger,
        val storedPublicExponent: BigInteger,
        val privateExponent: BigInteger,
        val primeP: BigInteger,
        val primeQ: BigInteger,
        val exponentP: BigInteger,
        val exponentQ: BigInteger,
        val crtCoefficient: BigInteger,
    )

    fun decode(pkcs1: ByteArray): DecodedKey {
        val parsed = try {
            parsePkcs1(pkcs1)
        } catch (_: IllegalArgumentException) {
            null
        }
        if (parsed != null && parsed.storedPublicExponent == parsed.privateExponent) {
            return try {
                DecodedKey(decodeLegacyDuplicateExponent(parsed), true)
            } catch (error: Exception) {
                throw InvalidKeyException("Invalid legacy RSA Push private key", error)
            }
        }

        try {
            return DecodedKey(
                KeyFactory.getInstance("RSA").generatePrivate(
                    PKCS8EncodedKeySpec(wrapPkcs1InPkcs8(pkcs1)),
                ),
                false,
            )
        } catch (error: GeneralSecurityException) {
            throw InvalidKeyException("Invalid RSA Push private key", error)
        }
    }

    private fun parsePkcs1(pkcs1: ByteArray): RsaComponents {
        val outer = DerReader(pkcs1)
        val sequence = outer.readSequence()
        outer.requireAtEnd()
        val result = RsaComponents(
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
            sequence.readPositiveInteger(),
        )
        sequence.requireAtEnd()
        return result
    }

    private fun decodeLegacyDuplicateExponent(key: RsaComponents): PrivateKey {
        require(key.version == ZERO) { "Only two-prime RSA keys are supported" }
        require(key.storedPublicExponent == key.privateExponent)
        require(key.modulus.bitLength() in 2048..8192) { "Unexpected RSA modulus" }
        require(key.primeP > ONE && key.primeQ > ONE && key.primeP != key.primeQ)
        require(key.modulus == key.primeP.multiply(key.primeQ))
        val pMinusOne = key.primeP.subtract(ONE)
        val qMinusOne = key.primeQ.subtract(ONE)
        require(key.exponentP == key.privateExponent.mod(pMinusOne))
        require(key.exponentQ == key.privateExponent.mod(qMinusOne))
        require(key.crtCoefficient == key.primeQ.modInverse(key.primeP))
        val lambda = pMinusOne.divide(pMinusOne.gcd(qMinusOne)).multiply(qMinusOne)
        val recoveredPublicExponent = key.privateExponent.modInverse(lambda)
        require(recoveredPublicExponent == RSA_PUBLIC_EXPONENT)
        return KeyFactory.getInstance("RSA").generatePrivate(
            RSAPrivateCrtKeySpec(
                key.modulus,
                recoveredPublicExponent,
                key.privateExponent,
                key.primeP,
                key.primeQ,
                key.exponentP,
                key.exponentQ,
                key.crtCoefficient,
            ),
        )
    }

    private fun wrapPkcs1InPkcs8(pkcs1: ByteArray): ByteArray {
        val version = byteArrayOf(0x02, 0x01, 0x00)
        val rsaAlgorithm = byteArrayOf(
            0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86.toByte(), 0x48, 0x86.toByte(),
            0xf7.toByte(), 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00,
        )
        val privateKey = byteArrayOf(0x04) + derLength(pkcs1.size) + pkcs1
        val body = version + rsaAlgorithm + privateKey
        return byteArrayOf(0x30) + derLength(body.size) + body
    }

    private fun derLength(length: Int): ByteArray {
        require(length >= 0)
        if (length < 128) return byteArrayOf(length.toByte())
        val bytes = ByteArray(4)
        var value = length
        var index = bytes.lastIndex
        while (value != 0) {
            bytes[index--] = (value and 0xff).toByte()
            value = value ushr 8
        }
        val encoded = bytes.copyOfRange(index + 1, bytes.size)
        return byteArrayOf((0x80 or encoded.size).toByte()) + encoded
    }

    private class DerReader(
        private val data: ByteArray,
        start: Int = 0,
        private val end: Int = data.size,
    ) {
        private var offset = start

        fun readSequence(): DerReader {
            require(readByte() == 0x30) { "Expected DER sequence" }
            val length = readLength()
            require(length <= end - offset) { "Truncated DER sequence" }
            val contentStart = offset
            offset += length
            return DerReader(data, contentStart, contentStart + length)
        }

        fun readPositiveInteger(): BigInteger {
            require(readByte() == 0x02) { "Expected DER integer" }
            val length = readLength()
            require(length > 0 && length <= end - offset) { "Invalid DER integer" }
            val first = data[offset].toInt() and 0xff
            require(first and 0x80 == 0) { "Negative DER integer" }
            if (length > 1 && first == 0) {
                require(data[offset + 1].toInt() and 0x80 != 0) {
                    "Non-minimal DER integer"
                }
            }
            val bytes = data.copyOfRange(offset, offset + length)
            offset += length
            return try {
                BigInteger(bytes)
            } finally {
                bytes.fill(0)
            }
        }

        fun requireAtEnd() {
            require(offset == end) { "Trailing DER data" }
        }

        private fun readLength(): Int {
            val first = readByte()
            if (first and 0x80 == 0) return first
            val count = first and 0x7f
            require(count in 1..4 && count <= end - offset) { "Invalid DER length" }
            require(data[offset].toInt() and 0xff != 0) { "Non-minimal DER length" }
            var length = 0
            repeat(count) { length = (length shl 8) or readByte() }
            require(length >= 128) { "Non-minimal DER length" }
            return length
        }

        private fun readByte(): Int {
            require(offset < end) { "Truncated DER data" }
            return data[offset++].toInt() and 0xff
        }
    }
}
