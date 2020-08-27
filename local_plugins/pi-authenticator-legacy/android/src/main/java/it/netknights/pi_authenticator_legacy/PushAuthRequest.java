/*
  privacyIDEA Authenticator

  Authors: Nils Behlen <nils.behlen@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

package it.netknights.pi_authenticator_legacy;

import java.util.Calendar;
import java.util.Date;

public class PushAuthRequest {
    private String nonce, url, serial, question, title, signature;
    private boolean sslVerify;
    private Date expiration;
    private int notificationID;

    public PushAuthRequest(String nonce, String url, String serial, String question, String title, String signature, int notificationID, boolean sslVerify) {
        this.nonce = nonce;
        this.url = url;
        this.serial = serial;
        this.question = question;
        this.title = title;
        this.signature = signature;
        this.sslVerify = sslVerify;
        // Add expiration time which is +2 Minutes
        Calendar now = Calendar.getInstance();
        now.add(Calendar.MINUTE, 2);
        this.expiration = now.getTime();
        this.notificationID = notificationID;
    }

    public int getNotificationID() {
        return notificationID;
    }

    public Date getExpiration() {
        return expiration;
    }

    public String getNonce() {
        return nonce;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getSerial() {
        return serial;
    }

    public void setSerial(String serial) {
        this.serial = serial;
    }

    public String getQuestion() {
        return question;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSignature() {
        return signature;
    }

    public boolean isSslVerify() {
        return sslVerify;
    }
}