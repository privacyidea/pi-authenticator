// SPDX-License-Identifier: Apache-2.0

package app.piauthenticator.channels

import java.math.BigInteger
import java.security.InvalidKeyException
import java.security.KeyPairGenerator
import java.security.Signature
import java.security.interfaces.RSAPrivateCrtKey
import java.security.interfaces.RSAPublicKey
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class PushPrivateKeyCodecTest {
    @Test
    fun decodesStandardPkcs1AndSigns() {
        val (privateKey, publicKey) = keyPair()
        val decoded = PushPrivateKeyCodec.decode(pkcs1(privateKey))

        assertFalse(decoded.repairedLegacyEncoding)
        assertTrue(signAndVerify(decoded.privateKey, publicKey))
    }

    @Test
    fun repairsExactDuplicateExponentEncodingAndSigns() {
        val (privateKey, publicKey) = keyPair()
        val decoded = PushPrivateKeyCodec.decode(
            pkcs1(privateKey, storedPublicExponent = privateKey.privateExponent),
        )

        assertTrue(decoded.repairedLegacyEncoding)
        assertTrue(signAndVerify(decoded.privateKey, publicKey))
    }

    @Test
    fun rejectsLegacyShapeWithInconsistentCrtParameters() {
        val (privateKey, _) = keyPair()
        val malformed = pkcs1(
            privateKey,
            storedPublicExponent = privateKey.privateExponent,
            exponentP = privateKey.primeExponentP.add(BigInteger.ONE),
        )

        assertThrows(InvalidKeyException::class.java) {
            PushPrivateKeyCodec.decode(malformed)
        }
    }

    private fun keyPair(): Pair<RSAPrivateCrtKey, RSAPublicKey> {
        val pair = KeyPairGenerator.getInstance("RSA").apply {
            initialize(2048)
        }.generateKeyPair()
        return Pair(pair.private as RSAPrivateCrtKey, pair.public as RSAPublicKey)
    }

    private fun signAndVerify(
        privateKey: java.security.PrivateKey,
        publicKey: RSAPublicKey,
    ): Boolean {
        val message = "Push PKCS#1 interoperability".toByteArray()
        val signature = Signature.getInstance("SHA256withRSA").run {
            initSign(privateKey)
            update(message)
            sign()
        }
        return Signature.getInstance("SHA256withRSA").run {
            initVerify(publicKey)
            update(message)
            verify(signature)
        }
    }

    private fun pkcs1(
        key: RSAPrivateCrtKey,
        storedPublicExponent: BigInteger = key.publicExponent,
        exponentP: BigInteger = key.primeExponentP,
    ): ByteArray = sequence(
        integer(BigInteger.ZERO),
        integer(key.modulus),
        integer(storedPublicExponent),
        integer(key.privateExponent),
        integer(key.primeP),
        integer(key.primeQ),
        integer(exponentP),
        integer(key.primeExponentQ),
        integer(key.crtCoefficient),
    )

    private fun sequence(vararg values: ByteArray): ByteArray {
        val body = values.fold(ByteArray(0)) { result, value -> result + value }
        return byteArrayOf(0x30) + length(body.size) + body
    }

    private fun integer(value: BigInteger): ByteArray {
        val encoded = value.toByteArray()
        return byteArrayOf(0x02) + length(encoded.size) + encoded
    }

    private fun length(value: Int): ByteArray {
        if (value < 128) return byteArrayOf(value.toByte())
        val raw = BigInteger.valueOf(value.toLong()).toByteArray()
            .dropWhile { it == 0.toByte() }
            .toByteArray()
        return byteArrayOf((0x80 or raw.size).toByte()) + raw
    }
}
