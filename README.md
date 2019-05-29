# disco_app

A Decentralized Self-contained OAuth 2.0 Service.

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
    "method": "PUT",
    "body": {
        "uid": "the uid I just pasted",
        "proxy_url": "https://[uid].localtunnel.me"
    },
}
```

5. Disco server receives the POST request from me, it will do these things:

- Tell IKEA how to contact me by sending an HTTP request to `https://ikea.com/callback` (which can be accessed from `client_callback` using the uid as the key) with the following config:

```json
{
    "method": "POST",
    "json": true,
    "body": {
        "proxy_url": "the proxy_url received from my POST request, which is https://[uid].localtunnel.me"
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

- Send an HTTP request to `proxy_url` (i.e. a tunnel to localhost:3000, where the OAuth 2.0 service is running on my phone) with the following config:

```json
{
    "method": "GET",
    "path": "/auth/register",
    "query_params": {
        "state": "a random string",
        "client_id": "IKEA's ID",
        "client_secret": "secret // client_id and secret is no different from username and password, so IKEA is free to generate these randomly as long as it keeps the record in its database and use the same pair of username&password to authenticate itself for the same user (me) next time",
        "client_name": "IKEA (optional)",
        "is_trusted": false
    },
    "headers": {
        "content-type": "text/plain",
        "challenge": "decrypted encrypted c  // since IKEA only received the encrypted c, it should be able to decrypt it and send it back to me for verification, also this challenge can be in the query parameters, storing non-standard information in headers is a bit strange, will change later"
    }
}
```

If I accepted the registration request, IKEA would receive a 200 OK response so that they can proceed to request for *key A*:

- Send an HTTP request to `proxy_url` with the following config:

```json
{
    "path": "/auth/authorize",
    "method": "GET",
    "query_params": {
        "state": "another random string",
        "client_id": "IKEA's ID",
        "client_secret": "secret",
        "client_name": "IKEA (optional)",
        "response_type": "token",
        "redirect_uri": "https://ikea.com/redirect   // this can be anything as we won't follow the redirect anyways, but it provides an alternative way of handling the callback",
        "scope": "key_b+address",
    },
    "followAllRedirects": false
}
```

If I accepted the *key A* request, IKEA would receive a 302 redirect with its request key inside. A sample response is as follows:

```json
// will add the sample response later
```

Note that the key is encoded and signed in [JSON Web Tokens](jwt.io) format so that we can make sure the scope, audience, expire time, everything about our token is not changed by anyone because we signed the token using a key known only to us. You may refer to the website for more information.

#### Step 2: Request and transfer *Key B*

// Add how IKEA finds me here, later

It is very similar to requesting *key A*, just the scope is different:

```json
{
    "path": "/auth/authorize",
    "method": "GET",
    "query_params": {
        "state": "another random string",
        "client_id": "IKEA's ID",
        "client_secret": "secret",
        "client_name": "IKEA (optional)",
        "response_type": "token",
        "redirect_uri": "https://ikea.com/redirect",
        "scope": "address",
        "audience": "Singpost",
        "certificate": "Singpost's certificate (optional, if the company wants to inform the user they only intend to share his address with Singpost it can add these extra information, but user's will decide in the end)"  
    },
    "followAllRedirects": false
}
```

If I accepted the *key B* request, IKEA would receive a 302 redirect with its request key inside. A sample response is as follows:

```json
// will add the sample response later
```

// Add how IKEA transfers *key B* to Singpost, later

#### Step 3: *Trusted Client* get the actual data

// add later
