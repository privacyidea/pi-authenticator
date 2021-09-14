/* Parts from The Android Open Source Project
 * Copyright (C) 2013 The Android Open Source Project
 *
 * privacyIDEA Authenticator
 *
 * Authors: Nils Behlen <nils.behlen@netknights.it>
 *
 * Copyright (c) 2017-2021 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package it.netknights.pi_authenticator_legacy;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
//import android.security.KeyPairGeneratorSpec;
//
//import androidx.annotation.RequiresApi;
//import java.math.BigInteger;
//
//import java.security.KeyPairGenerator;
//import java.security.InvalidAlgorithmParameterException;
//import java.security.NoSuchProviderException;
//import java.security.PublicKey;
//import java.util.Calendar;
//import java.util.GregorianCalendar;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.KeyPair;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.UnrecoverableEntryException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.security.auth.x500.X500Principal;

import static it.netknights.pi_authenticator_legacy.AppConstants.KEY_WRAP_ALGORITHM;
import static it.netknights.pi_authenticator_legacy.Util.logprint;

/**
 * Wraps {@link SecretKey} instances using a public/private key pair stored in
 * the platform {@link KeyStore}. This allows us to protect symmetric keys with
 * hardware-backed crypto, if provided by the device.
 * <p>
 * See <a href="http://en.wikipedia.org/wiki/Key_Wrap">key wrapping</a> for more
 * details.
 * <p>
 * Not inherently thread safe.
 */
public class SecretKeyWrapper {
    private final Cipher mCipher;
    private final KeyPair mPair;

    /**
     * Create a wrapper using the public/private key pair with the given alias.
     * If no pair with that alias exists, it will be generated.
     */
    @SuppressLint("GetInstance")
    public SecretKeyWrapper(Context context)
            throws GeneralSecurityException, IOException {
        mCipher = Cipher.getInstance(KEY_WRAP_ALGORITHM);

        final KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);

        // TODO This should not be needed?
        if (!keyStore.containsAlias("settings")) {
            mPair = null;
            return;
        }

        // Even if we just generated the key, always read it back to ensure we
        // can read it successfully.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            //Following code is for API 28+
            PrivateKey privateKey = (PrivateKey) keyStore.getKey("settings", null);

            Certificate certificate = keyStore.getCertificate("settings");
            KeyStore.PrivateKeyEntry entry = new KeyStore.PrivateKeyEntry(privateKey, new Certificate[]{certificate});
            mPair = new KeyPair(entry.getCertificate().getPublicKey(), entry.getPrivateKey());
        } else {
            final KeyStore.PrivateKeyEntry entry = (KeyStore.PrivateKeyEntry) keyStore.getEntry("settings", null);
            mPair = new KeyPair(entry.getCertificate().getPublicKey(), entry.getPrivateKey());
        }

        /*final PrivateKey privateKey = (PrivateKey) keyStore.getKey("alias", null);
        final PublicKey publicKey = privateKey != null ? keyStore.getCertificate("alias").getPublicKey() : null;
        mPair = new KeyPair(publicKey, privateKey);*/
    }

    /**
     * Wrap a {@link SecretKey} using the public key assigned to this wrapper.
     * Use {@link #unwrap(byte[])} to later recover the original
     * {@link SecretKey}.
     *
     * @return a wrapped push_version of the given {@link SecretKey} that can be
     * safely stored on untrusted storage.
     */
    public byte[] wrap(SecretKey key) throws GeneralSecurityException {
        mCipher.init(Cipher.WRAP_MODE, mPair.getPublic());
        return mCipher.wrap(key);
    }

    /**
     * Unwrap a {@link SecretKey} using the private key assigned to this
     * wrapper.
     *
     * @param blob a wrapped {@link SecretKey} as previously returned by
     *             {@link #wrap(SecretKey)}.
     */
    public SecretKey unwrap(byte[] blob) throws GeneralSecurityException {
        mCipher.init(Cipher.UNWRAP_MODE, mPair.getPrivate());

        return (SecretKey) mCipher.unwrap(blob, "AES", Cipher.SECRET_KEY);
    }

//    /**
//     * Generate a KeyPair and store it with the given alias in the KeyStore.
//     * Return the PublicKey
//     *
//     * @param alias   the alias to store the key with
//     * @param context needed for KeyPairGeneratorSpec
//     * @return the PublicKey of the just generated KeyPair
//     */
//    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
//    public static PublicKey generateKeyPair(String alias, Context context) throws KeyStoreException, CertificateException, NoSuchAlgorithmException, IOException,
//            NoSuchProviderException, InvalidAlgorithmParameterException, UnrecoverableEntryException {
//        final KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
//        keyStore.load(null);
//        logprint("generateKeyPair for alias: " + alias);
//        if (keyStore.containsAlias(alias)) {
//            // TODO double entry_normal -> overwrite?
//        }
//        final Calendar start = new GregorianCalendar();
//        final Calendar end = new GregorianCalendar();
//        end.add(Calendar.YEAR, 100);
//        final KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA", "AndroidKeyStore");
//        final KeyPairGeneratorSpec spec = new KeyPairGeneratorSpec.Builder(context)
//                .setAlias(alias)
//                .setSubject(new X500Principal("CN=" + alias))
//                .setSerialNumber(BigInteger.ONE)
//                .setStartDate(start.getTime())
//                .setEndDate(end.getTime())
//                .setKeySize(4096)
//                .build();
//        gen.initialize(spec);
//        gen.generateKeyPair();
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//            //Following code is for API 28+
//            PrivateKey privateKey = (PrivateKey) keyStore.getKey(alias, null);
//            Certificate certificate = keyStore.getCertificate(alias);
//            return new KeyStore.PrivateKeyEntry(privateKey, new Certificate[]{certificate}).getCertificate().getPublicKey();
//        } else {
//            final KeyStore.PrivateKeyEntry entry = (KeyStore.PrivateKeyEntry) keyStore.getEntry(alias, null);
//            return entry.getCertificate().getPublicKey();
//        }
//    }

    /**
     * Load the PrivateKey for the given alias/serial
     *
     * @param alias the alias to load the key for
     * @return the PrivateKey
     */
    public PrivateKey getPrivateKeyFor(String alias) throws CertificateException, NoSuchAlgorithmException, IOException, KeyStoreException, UnrecoverableEntryException {
        final KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);
        if (!keyStore.containsAlias(alias)) {
            // TODO key not found
            return null;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            //Following code is for API 28+
            PrivateKey privateKey = (PrivateKey) keyStore.getKey(alias, null);
            Certificate certificate = keyStore.getCertificate(alias);
            return new KeyStore.PrivateKeyEntry(privateKey, new Certificate[]{certificate}).getPrivateKey();
        } else {
            final KeyStore.PrivateKeyEntry entry = (KeyStore.PrivateKeyEntry) keyStore.getEntry(alias, null);
            return entry.getPrivateKey();
        }
    }

    /**
     * Remove the privateKey from the Keystore for the given alias/serial
     *
     * @param alias the serial is the alias of the privateKey in the Keystore
     */
    public void removePrivateKeyFor(String alias) {
        try {
            final KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
            keyStore.load(null);
            if (!keyStore.containsAlias(alias)) {
                logprint("key for alias " + alias + " was not found for deletion!");
                return;
            }
            keyStore.deleteEntry(alias);
            logprint("key for alias " + alias + " was deleted from keystore!");
        } catch (KeyStoreException | CertificateException | NoSuchAlgorithmException | IOException e) {
            e.printStackTrace();
        }
    }

}