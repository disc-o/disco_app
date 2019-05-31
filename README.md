# Disco App

A Decentralized Self-contained OAuth-2.0-like Service, running on both Android and iOS.

This service aims to achieve all-round control over personal information by letting mobile devices to act as authorization servers hosting the information of the device's owner. End-to-end encryption means you don't even need to trust the Disco server.

## Getting Started

```bash
cd ~/Android/Sdk/platform-tools
./adb forward tcp:3000 tcp:3000
./adb reverse tcp:3001 tcp:3001
lt --subdomain disco-app --port 3000
```

Then fire up `disco_server` and `disco_client`.

Enter `localhost:3002`, get the UID from that page.
Change *Proxy URL* to `https://disco-app.localtunnel.me`, click *Update*
Click *Start server* and then click *Connect remote*

## Overview

### Motivation

The only way of truly preserving privacy is to have control over any information you shared with others. However, by the nature of information, such dream is impossible to realize - take Snapchat as an example, even if the message destroys itself in a set period of time, you can always take a picture of the piece of information before it disappears. In other words, we have to make some compromises here - we make sure the information is visible only to trusted parties and no one else. In other words, in a privacy-first information sharing system, we only trust those who have direct connection with that piece of information (e.g. the post office needs your address to deliver your parcel while IKEA who tries to send you their magazines doesn't; the Uber driver needs your address to pick you up while Uber doesn't, etc.).

### Terms

(Keep in mind that keys, trusted or not are relative to a specific piece of data. We don't trust anyone for all of our information. We trust them for certain pieces of our information)

**Trusted client:** the client who can read the information in "plaintext" (e.g. post office in *Motivation*)

**Untrusted client:** the client who can't read *the* information as "plaintext" but is able to make use of it (under *user's* control of course, *user* will be notified and have to approve their usage of *user's* information when *untrusted client* attempt to do so) (e.g. IKEA in *Motivation*)

**User:** the owner of information (e.g. yourself)

**Key A:** the key *untrusted clients* receive from *user* after they informed *user* that they **may** make use of their information in the future

**Key B:** the key *untrusted clients* receive from *user* when they informed *user* they will send their information to *trusted client* to do something (e.g. send them IKEA magazines); *key B* will then be sent to *trusted client*

***Note:*** Although *untrusted client* is the one who receives *key B*, it is not the final recipient of *key B* because it cannot make use of it. *Trusted client* will exchange documents proving their identity and *key B* for *user's* information

### How *Disco* protocol works

There are three parts to a typical *Disco* system:

- Disco server, who's in charge of pairing up *client* and *user*, and create a secure HTTPS tunnel between them
- Disco app, the user-side application where data is stored and *user* approve/reject data requests
- Client server, including *trusted clients* and *untrusted clients*

Imagine 

1. *user* is required to fill in their address on an *untrusted client's* website - *untrusted client* requests for *key A*
2. then *untrusted client* decides to send a parcel to *user* - *untrusted client* requests for *key B* and sends *key B* to *trusted client*
3. *trusted client* is about to deliver the parcel and needs the actual address - *trusted client* exchange documents proving their identity and *key B* for *user's* information

From this point onwards I will use the scenario above, and I will take *IKEA* as the *untrusted client*, *Singpost* as the *trusted client*, *me* as the *user*.

Also, I assume the root domain of Disco server is `https://dis.co`

#### Step 1: Initiate the data request

1. IKEA's website send an HTTP request to `https://dis.co/uid` with the following config:
```json
{
    "method": "GET",
    "query_params": {
        "callback": "https://ikea.com/callback"
    },
    "headers": {
        "Authorization": "-----BEGIN CERTIFICATE-----\
                        MIIDGTCCAgECFDJp0BJ+af9z/rLYiT7P2f+xFmQKMA0GCSqGSIb3DQEBCwUAMEkx\
                        CzAJBgNVBAYTAlNHMRIwEAYDVQQIDAlTaW5nYXBvcmUxEjAQBgNVBAcMCVNpbmdh\
                        cG9yZTESMBAGA1UECgwJRHVtbXkgQ28uMB4XDTE5MDUyODEzMzcwMVoXDTIwMDUy\
                        NzEzMzcwMVowSTELMAkGA1UEBhMCU0cxEjAQBgNVBAgMCVNpbmdhcG9yZTESMBAG\
                        A1UEBwwJU2luZ2Fwb3JlMRIwEAYDVQQKDAlEdW1teSBDby4wggEiMA0GCSqGSIb3\
                        DQEBAQUAA4IBDwAwggEKAoIBAQDJDtjJzwW7DjZb9SreSzYE1f8S9dWoWDD9ebom\
                        DAeURUjxEp7Ww0Fr44iVqZnizilrzffrh+HxWTZSxkd42wIlzfvPdeXZYnelSBQq\
                        C3wcfZeaY7sJEDciDtnsg6gAqInToiKnX7zKL7vJQULyND+0Z3NV8ET3NnTSew40\
                        xRqxOqya3NIWaPexPcHA+kXsdgllIDUrXiyxVQT+f4g15QnTk7OVGSu2R0tUYI7B\
                        rRJeJ/6gFpr7aY3ebdUQKSAPHh5fHcehO26ti0suYjlwA7wvjZzSuFXVVo8Flt/i\
                        4Aqv65DuGqw/PWwn6xeaiZVAhY85RHqegkbdr1lX1wVwCNX5AgMBAAEwDQYJKoZI\
                        hvcNAQELBQADggEBAIPTbCUmc818sz16y30akXM+IUF5s/Sc2Fq4ZIiF8qn13XiI\
                        5s/M3IQz5RcrhU7+uAvspL4uVQZqH6ztZsnYSf+mQL563hWo0WUpx686D2ySPBnw\
                        KPLsjagCmyfwRtaKpm3zn/wXZJDl4HalQMDHv7Uy1Uy0P9BIxpMvFCFVu0eoW/5R\
                        pqLy6JtJtOFq/X0jvjRvdz1xYo19dx3FYk36sxzHm+yE4ch82jHU8tVW8+kYEDqF\
                        nrSt9KK7vDxAWT1MMD4EuknrxifHrFfxTf9WVfhsXX4WTK/QfFgQwTsSZaw/ITK7\
                        DlnX6jLae5qaZAsIOUjCViURMfSgSNVGR50S4ww=\
                        -----END CERTIFICATE-----"
    }
}
```
2. Disco server will do these things:

- Add an entry to `Map client_callback`, where the key is **uid** and the value is **callback** in the query parameters
- Add an entry to `Map client_certificate`, where the key is **uid** and the value is **Authorization** in the headers
- Generate a 128-byte long challenge *c*
- Add an entry to `Map client_challenge`, where the key is **uid** and the value is *c*
- Respond IKEA with a JSON in format like:

```json
{
    "uid": "a random 8-byte unique id",
    "challenge": "c encrypted with public key contained in the certificate of IKEA"
}
```

3. IKEA display the **uid** on their website, I copy the uid into Disco app
4. I open Disco app, paste uid, click connect. Disco app will do these things:

- Open a local HTTP server listening on port 3000
- Create a tunnel connection with Disco server, get a public URL like `https://[uid].localtunnel.me`. From this point onwards, accessing `https://[uid].localtunnel.me` from the Internet is no different from accessing `localhost:3000` on the phone (i.e. we exposed the phone's localhost to the Internet)
- Send an HTTP request to `https://dis.co/uid` with the following config:

```json
{
    "method": "POST",
    "body": {
        "uid": "the uid I just pasted",
        "proxy_url": "https://[uid].localtunnel.me",
        "public_key": "-----BEGIN PUBLIC KEY-----MIIBCgKCAQEAsBUse4hn0lx0AwZrH40JwFJMrgJCEh7mg7U\PHtrydJjs5utv279reBqO6kZiXSN4dhIgN3fg9jxvwQcDDs46nKDozNbmjp1jPxYwHVGYk91Rhvspcuh5CZlQIZp9KjRH9lG0tjolyNOQEDsPQH5Oc6f9NPIcOALrWQ++wLX7nVbe5TlsZv0Lz/wJJqafCLtjEW5LuHsIwyg+h3Vkf5xKahpwLEHcX1rFyvc0FPy9QALzycrtKzXpq6WZ/pco++wt+E/iZIXFApCZILacK/xoHKbZipYoPPJBjpHD8/5nqB9Bj1rRNgPeMtNTnbBbktvXshjoy5dQtNr3qygGB1cywIDAQAB-----END PUBLIC KEY-----",
    },
}
```

By providing a `public_key`, I don't need to trust Disco server's tunnel service
- Later IKEA will encrypt its `client_id` and `client_secret` using my public key so that even if Disco server wants to steal IKEA's id and secret, it can't read it as plaintext
- When IKEA wants to exchange its `client_id`, `client_secret` and *key A* for *key B*, it will encode these information in a JSON string, encrypt it using my public key. Since Disco server doesn't have IKEA's id and secret as plaintext, it can does nothing but honestly pass the data without changing a byte because changing any information would result in an unreadable response received by me, which I will of course reject.

5. Disco server receives the POST request from me, it will do these things:

- Tell IKEA how to contact me by sending an HTTP request to `https://ikea.com/callback` (which can be accessed from `client_callback` using the uid as the key) with the following config:

```json
{
    "method": "POST",
    "json": true,
    "body": {
        "proxy_url": "the proxy_url received from my POST request, which is https://[uid].localtunnel.me",
        "public_key": "-----BEGIN PUBLIC KEY-----MIIBCgKCAQEAsBUse4hn0lx0AwZrH40JwFJMrgJCEh7mg7U\PHtrydJjs5utv279reBqO6kZiXSN4dhIgN3fg9jxvwQcDDs46nKDozNbmjp1jPxYwHVGYk91Rhvspcuh5CZlQIZp9KjRH9lG0tjolyNOQEDsPQH5Oc6f9NPIcOALrWQ++wLX7nVbe5TlsZv0Lz/wJJqafCLtjEW5LuHsIwyg+h3Vkf5xKahpwLEHcX1rFyvc0FPy9QALzycrtKzXpq6WZ/pco++wt+E/iZIXFApCZILacK/xoHKbZipYoPPJBjpHD8/5nqB9Bj1rRNgPeMtNTnbBbktvXshjoy5dQtNr3qygGB1cywIDAQAB-----END PUBLIC KEY-----",
    }
}
```

- Respond me with the challenge *c* and IKEA's certificate for my verification of IKEA's identity

```json
{
    "challenge": "c, not encrypted",
    "certificate": "client_certificate[uid], which is the certificate IKEA sent to Disco server in the first place"
}
```

6. IKEA server will try to contact me after receiving `proxy_url` from Disco server, it will do these things:

If IKEA has never contacted me before, it needs to register itself on my Disco app first:

- Encode the following JSON to a string, then encrypt it using `public_key` to JSON `p` (because the mathematical limitation of RSA algorithm, it is impossible to directly encrypt a message that's too long, so we randomly generate a 16-byte long key and 16-byte long initialization vector, using [AES-CBC](https://tools.ietf.org/html/rfc3602), a symmetric encryption algorithm with no length limitation to encrypt the message, then use the public key to encrypt these two short strings.)

```json
{
    "state": "a random string",
    "client_id": "IKEA's ID (encrypted with public_key received earilier)",
    "client_secret": "secret (encrypted)",
    "client_name": "IKEA (optional)",
    "is_trusted": false,
    "certificate": "-----BEGIN CERTIFICATE-----MIIDGTCCAgECFDJp0BJ+af9z/rLYiT7P2f+xFmQKMA0GCSqGSIb3DQEBCwUAMEkxCzAJBgNVBAYTAlNHMRIwEAYDVQQIDAlTaW5nYXBvcmUxEjAQBgNVBAcMCVNpbmdhcG9yZTESMBAGA1UECgwJRHVtbXkgQ28uMB4XDTE5MDUyODEzMzcwMVoXDTIwMDUyNzEzMzcwMVowSTELMAkGA1UEBhMCU0cxEjAQBgNVBAgMCVNpbmdhcG9yZTESMBAGA1UEBwwJU2luZ2Fwb3JlMRIwEAYDVQQKDAlEdW1teSBDby4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDJDtjJzwW7DjZb9SreSzYE1f8S9dWoWDD9ebomDAeURUjxEp7Ww0Fr44iVqZnizilrzffrh+HxWTZSxkd42wIlzfvPdeXZYnelSBQqC3wcfZeaY7sJEDciDtnsg6gAqInToiKnX7zKL7vJQULyND+0Z3NV8ET3NnTSew40xRqxOqya3NIWaPexPcHA+kXsdgllIDUrXiyxVQT+f4g15QnTk7OVGSu2R0tUYI7BrRJeJ/6gFpr7aY3ebdUQKSAPHh5fHcehO26ti0suYjlwA7wvjZzSuFXVVo8Flt/i4Aqv65DuGqw/PWwn6xeaiZVAhY85RHqegkbdr1lX1wVwCNX5AgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIPTbCUmc818sz16y30akXM+IUF5s/Sc2Fq4ZIiF8qn13XiI5s/M3IQz5RcrhU7+uAvspL4uVQZqH6ztZsnYSf+mQL563hWo0WUpx686D2ySPBnwKPLsjagCmyfwRtaKpm3zn/wXZJDl4HalQMDHv7Uy1Uy0P9BIxpMvFCFVu0eoW/5RpqLy6JtJtOFq/X0jvjRvdz1xYo19dx3FYk36sxzHm+yE4ch82jHU8tVW8+kYEDqFnrSt9KK7vDxAWT1MMD4EuknrxifHrFfxTf9WVfhsXX4WTK/QfFgQwTsSZaw/ITK7DlnX6jLae5qaZAsIOUjCViURMfSgSNVGR50S4ww=-----END CERTIFICATE-----",
    "challenge": "decrypted encrypted c  // since IKEA only received the encrypted c, it should be able to decrypt it and send it back to me for verification, also this challenge can be in the query parameters, storing non-standard information in headers is a bit strange, will change later"
}
```

The resulting JSON `p` should be in the format and look like:

```json
{
    "key": "Q8ZtJzfYq_RwYndUaW98_3Xzq1mjK-CSXlB-dhGtl_rIPPZ1SwIMoX5VnhjL3mBe0SMv5LjJxf5caJtp30O6lt599o6emGJ8FWF7SoKdNnfhAFn3MRcyOqw9je1-SM0e9C29kP2VrtereJcU0s21Z0xuu1nBSArnEVlawu_OfbZJPubCn9yg-Bvgu0kLzGgN2UUmU5qFCKZt9bGhCIP-S1xcQfoYm9o1B60b5QPVDTa1qPs6h6ewJVPShPRrT-FlSuEnTiRInZGoxwjQhoV6Xak0sNypOHfkQf_HLrl4GoNut-hJ2aTZot-rwNg-Q2RjTXXY8bXExw0XySk77r990A==",
    "iv": "dD_-nInLEq3s-AUVpl91R9ap_FWtLDEYsz4IR7IkLgCUPjf-z6k_Ht-vQyCyGcJPtwSNR8QHSQDJO93-jXtxs0Rz7PtDCB5mOYSoNhdQiTQemfk4cz1y5SxHaCA10SZExH2MsTanwlCghKQqU7tbfubWTfiLT1qCbeLrg3pRB5WXUJQcD6GaOW9FLX7yxKhjrqJ19xpVp0vdGdndKwsjLSpMZEfrygH2ANC5-6dbNHM32X1gGK609HPB-N4sPN8xAcd3HQgc4qW7xpxkc2fqljmDZDVniclBogd0Kaw9tull7u_3r_-j4-SDvfDiyz68S7caSjyKWOd8hZrqoG8I1g==",
    "encrypted": "A/za/mN2itMIZNiRYGq0IUFeYgfcqary0AOyoa0DgKolqO+qVXu0NUaLfOU46jf/I0LyifAUiX7GK5eFy3NUOvEouW1nqf8IgdiN8S0srYgcpKLzeDfSpk3WPNlIPgiIFMhzNSVwlVYHKE8cRQezU3R6qrSYK2MwOS1SmI5Fzs3N3dRjAPUC247XVzqJz9nysWaFBJtNM6f2+IwOCWqlPQ=="
}
```

**Note:** all byte array data, if without mentioning, are encoded in Base64.

- Send an HTTP request to `proxy_url` (i.e. a tunnel to localhost:3000, where the OAuth 2.0 service is running on my phone) with the following config:

```json
{
    "method": "POST",
    "path": "/auth/register",
    "headers": {
        "content-type": "application/json",
    },
    "body": {
        "data": `p`
    }
}
```

If I accepted the registration request, IKEA would receive a 200 OK response so that they can proceed to request for *key A*:

- Encode the following JSON to a string, then encrypt it using `public_key` to JSON `s` in a similar way mentioned above

**Note:** 

- The scope should be encoded in this way: every scope is one word without "+" inside the word, and use "+" to connect different scopes.
- If the scope does not contain keyword `key_b`, it would be considered a request for *key B* instead of *key A*

```json
{
    "client_id": "IKEA's ID (encrypted)",
    "client_secret": "secret (encrypted)",
    "response_type": "token",
    "redirect_uri": "https://ikea.com/redirect",
    "scope": "key_b+address",
}
```

The resulting JSON `s` should be in the format and look like:

```json
{
    "key": "Oe1l4RqZY-5G0ZWh9GX_R4M87aKc-w3uJQEfH1_nSRLdVxMy6DmTIgHfI97oyhAbDvpPaSbS9kv0sqGKZf_Gj1W57E8GV7mN3zRbCUeyUG7Kjps_ii6ABoVbt4iXYAPT_-v0O_8CQtldv9iDWgmh0Rr2u-TaZIqFljtsxoVd5rp4GLybHoGRWktxWWvI9aLfKiVyIMsftiVNJzJASFnewI1T6UcubhPrtqyX1xACpBrOJ3a-ZJLk6D-SGtMOb7MEvrDqAryGZiwasCM83a5Czrxlj9lSJPupZM8VulnCghd3gAuxa6LnDeRNjbvQr2SoIBivWc6W05hS4fs40O1iNg==",
    "iv": "LcZLp2Uy0hwnuB4sl5ha46fMCTqBUnxZ-iZM8B3lQBp5MxGreHXgEjwUuOQ2FkJOtprxguSvwAj6FeF9rARkKK7TmPBQ6D3PCsLnRE95Vo-4QzZq5kNizT-A7EEH1TRJiz0i_M4OACbgarb0DV2nXdyKkC-9zl70Ghi6HvDlOsnwQ9IM3SB0jk5lcdZ7-FsWoEZPnBHr7HzjoVPQBigQ2nOSkn8CPK0m0e-VDhI6C0hPNq31o716USWDNcDv8ko7GQwCSt0o2vqv9A1xEYXZggQDjPu9wjeI0cEuTq_Gozkx3XjOhWCTf9-dpMctimXOsq9Jokk4jbmibPkWdWaNYw==",
    "encrypted": "KRscl3hxHhgho4ZvpenNS+ov1Ud7aAlnKtXthOxi+xu8YTjukrhrFEHU/B9Sk7UrgmvIj0qzyWwRyIkACPHwgkq+5eFYmb7a43kZbM/I+GJMPtUTYVuUuTL+/XaIxbpyymGaoFIGOB8ZGfhxNSRXWP8Zpif48FgruUD9DS0fQwNodFR3tEqjrSNxg/C1wR4a"
}
```

- Send an HTTP request to `proxy_url` with the following config:

```json
{
    "path": "/auth/authorize",
    "method": "GET",
    "query_params": {
        "state": "another random string",
        "client_name": "IKEA (optional)",
        "data": `s`
    },
    "followAllRedirects": false
}
```

If I accepted the *key A* request, IKEA would receive a JSON response with its request key inside. A sample response is as follows:

```json
{
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjMwMDAiLCJleHAiOjE1NTkyMDc5MjEsImlhdCI6MTU1OTIwNzg2MSwiYXVkIjoiaHR0cDovLzEyNy4wLjAuMTozMDAwIiwic3ViIjoiSUtFQSdzIElEIiwic2NvcGVzIjpbImtleV9iIiwiYWRkcmVzcyJdfQ.prdN7JH0FljxBDMKdyywws8WX-3XonErvuQnc7HUh5s",
    "token_type": "bearer",
    "expires_in": 60,
    "scope": [
        "key_b",
        "address"
    ]
}
```

Note that the key is encoded and signed in [JSON Web Tokens](jwt.io) format so that we can make sure the scope, audience, expire time, everything about our token is not changed by anyone because we signed the token using a key known only to us. You may refer to the website for more information. Also, according to [this answer on Stackoverflow](https://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers), our URL *should* be within the 2000 character limit. However we're dealing with servers instead of browsers so even if it exceeded the length limit it should be no problem....

#### Step 2: Request and transfer *Key B*

// IKEA finds me via the push notification service

- Encode the following JSON to a string, then encrypt it using `public_key` to JSON `ss`

```json
{
    "access_token": "key A received earilier",
    "client_id": "IKEA's ID",
    "client_secret": "secret",
    "response_type": "token",
    "redirect_uri": "https://ikea.com/redirect",
    "scope": "address",
    "audience": "Singpost",
}
```

- Send an HTTP request to `proxy_url` with the following config:

```json
{
    "path": "/auth/authorize",
    "method": "GET",
    "query_params": {
        "state": "another random string",
        "client_name": "IKEA (optional)",
        "certificate": "Singpost's certificate (optional, if the company wants to inform the user they only intend to share his address with Singpost it can add these extra information, but user's will decide in the end)",
        "data": `ss`
    },
    "followAllRedirects": false
}
```

If I accepted the *key B* request, IKEA would receive a JSON response with its request key inside. Of course, because of the end-to-end encryption, the raw response is contains `key` and `iv` which are encrypted with IKEA's public key and a `encrypted` which an encrypted JSON string using `key` and `iv`. A sample decrypted and parsed response is as follows:

```json
{
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjMwMDAiLCJleHAiOjE1NTkyMDc5MjEsImlhdCI6MTU1OTIwNzg2MSwiYXVkIjoiaHR0cDovLzEyNy4wLjAuMTozMDAwIiwic3ViIjoiSUtFQSdzIElEIiwic2NvcGVzIjpbImtleV9iIiwiYWRkcmVzcyJdfQ.prdN7JH0FljxBDMKdyywws8WX-3XonErvuQnc7HUh5s",
    "token_type": "bearer",
    "expires_in": 36000,
    "scope": [
        "address"
    ]
}
```

Then IKEA sends this JSON to Singpost.

#### Step 3: *Trusted Client* get the actual data

By now you should be familiar with how end-to-end encryption works, remember whenever sends a message to me, Singpost would first stringify its JSON and encrypt it with AES and send me the encrypted `key` and `iv` using my public key, along with `encrypted`; whenever I send a message to Singpost, I would do the same using the public key from Singpost's certificate

The registration process is exactly the same as IKEA's. The only difference is that Singpost requests for a *trusted client* privilege:

```json
{
    "state": "a random string",
    "client_id": "Singpost's ID",
    "client_secret": "secret",
    "client_name": "Singpost",
    "is_trusted": true,
    "certificate": data.sampleCertificate,
    "challenge": "decrypted encrypted c"
}
```

Requesting for data is exactly the same as how IKEA request for *key B*, a sample request JSON is as follows:

```json
{
    "access_token": "key B obtained from IKEA",
    "client_id": "IKEA's ID",
    "client_secret": "secret",
    "response_type": "token",
    "redirect_uri": "https://singpost.sg/redirect",
    "scope": "address",
    "audience": "Singpost",
}
```

If I approve this request, Singpost would receive my information in JSON format (encrypted with Singpost's public key of course):

```json
{
    "address": "my address"
}
```

## Limitations

1. Since *user* doesn't have the ability to own a CA-signed certificate, Disco server cannot make sure information sent from *client* is safe. However, our system aims to protect *user*'s privacy, not the *client*'s, this is an unavoidable flaw that doesn't matter much.
2. Currently we don't have a [localtunnel](https://localtunnel.github.io/www/) or similar tunneling client written in Dart, so this app can only run on emulators where we can forward `localhost:3000` of the emulator to `localhost:3000` of our computer, then on the computer, create a tunnel from `localhost:3000` to localtunnel's server.
3. Currently we don't have a complete PKI utility library written in Dart. Specifically we can't parse X.509 certificate encoded in PEM within our app, so I integrated this function to [Disco server](https://github.com/disc-o/server) under POST request of `/cert` route.

Clearly limitation 2 and 3 can be solved by porting the standard implementations, which takes time.