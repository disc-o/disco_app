class ParsedX509Certificate {
  String publicKey;
  List<Extensions> extensions;
  Issuer issuer;
  String serialNumber;
  Siginfo siginfo;
  String signature;
  Subject subject;
  Validity validity;
  int version;

  ParsedX509Certificate(
      {this.publicKey,
      this.extensions,
      this.issuer,
      this.serialNumber,
      this.siginfo,
      this.signature,
      this.subject,
      this.validity,
      this.version});

  ParsedX509Certificate.fromJson(Map<String, dynamic> json) {
    publicKey = json['public_key'];
    if (json['extensions'] != null) {
      extensions = new List<Extensions>();
      json['extensions'].forEach((v) {
        extensions.add(new Extensions.fromJson(v));
      });
    }
    issuer =
        json['issuer'] != null ? new Issuer.fromJson(json['issuer']) : null;
    serialNumber = json['serialNumber'];
    siginfo =
        json['siginfo'] != null ? new Siginfo.fromJson(json['siginfo']) : null;
    signature = json['signature'];
    subject =
        json['subject'] != null ? new Subject.fromJson(json['subject']) : null;
    validity = json['validity'] != null
        ? new Validity.fromJson(json['validity'])
        : null;
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['public_key'] = this.publicKey;
    if (this.extensions != null) {
      data['extensions'] = this.extensions.map((v) => v.toJson()).toList();
    }
    if (this.issuer != null) {
      data['issuer'] = this.issuer.toJson();
    }
    data['serialNumber'] = this.serialNumber;
    if (this.siginfo != null) {
      data['siginfo'] = this.siginfo.toJson();
    }
    data['signature'] = this.signature;
    if (this.subject != null) {
      data['subject'] = this.subject.toJson();
    }
    if (this.validity != null) {
      data['validity'] = this.validity.toJson();
    }
    data['version'] = this.version;
    return data;
  }
}

class Extensions {
  String id;
  bool critical;
  String value;
  String name;
  bool digitalSignature;
  bool nonRepudiation;
  bool keyEncipherment;
  bool dataEncipherment;
  bool keyAgreement;
  bool keyCertSign;
  bool cRLSign;
  bool encipherOnly;
  bool decipherOnly;

  Extensions(
      {this.id,
      this.critical,
      this.value,
      this.name,
      this.digitalSignature,
      this.nonRepudiation,
      this.keyEncipherment,
      this.dataEncipherment,
      this.keyAgreement,
      this.keyCertSign,
      this.cRLSign,
      this.encipherOnly,
      this.decipherOnly});

  Extensions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    critical = json['critical'];
    value = json['value'];
    name = json['name'];
    digitalSignature = json['digitalSignature'];
    nonRepudiation = json['nonRepudiation'];
    keyEncipherment = json['keyEncipherment'];
    dataEncipherment = json['dataEncipherment'];
    keyAgreement = json['keyAgreement'];
    keyCertSign = json['keyCertSign'];
    cRLSign = json['cRLSign'];
    encipherOnly = json['encipherOnly'];
    decipherOnly = json['decipherOnly'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['critical'] = this.critical;
    data['value'] = this.value;
    data['name'] = this.name;
    data['digitalSignature'] = this.digitalSignature;
    data['nonRepudiation'] = this.nonRepudiation;
    data['keyEncipherment'] = this.keyEncipherment;
    data['dataEncipherment'] = this.dataEncipherment;
    data['keyAgreement'] = this.keyAgreement;
    data['keyCertSign'] = this.keyCertSign;
    data['cRLSign'] = this.cRLSign;
    data['encipherOnly'] = this.encipherOnly;
    data['decipherOnly'] = this.decipherOnly;
    return data;
  }
}

class Issuer {
  List<Attributes> attributes;
  String hash;

  Issuer({this.attributes, this.hash});

  Issuer.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      attributes = new List<Attributes>();
      json['attributes'].forEach((v) {
        attributes.add(new Attributes.fromJson(v));
      });
    }
    hash = json['hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes.map((v) => v.toJson()).toList();
    }
    data['hash'] = this.hash;
    return data;
  }
}

class Attributes {
  String type;
  String value;
  int valueTagClass;
  String name;
  String shortName;

  Attributes(
      {this.type, this.value, this.valueTagClass, this.name, this.shortName});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
    valueTagClass = json['valueTagClass'];
    name = json['name'];
    shortName = json['shortName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    data['valueTagClass'] = this.valueTagClass;
    data['name'] = this.name;
    data['shortName'] = this.shortName;
    return data;
  }
}

class Siginfo {
  String algorithmOid;

  Siginfo({this.algorithmOid});

  Siginfo.fromJson(Map<String, dynamic> json) {
    algorithmOid = json['algorithmOid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['algorithmOid'] = this.algorithmOid;
    return data;
  }
}

class Subject {
  List<Attributes> attributes;
  String hash;

  Subject({this.attributes, this.hash});

  Subject.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      attributes = new List<Attributes>();
      json['attributes'].forEach((v) {
        attributes.add(new Attributes.fromJson(v));
      });
    }
    hash = json['hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes.map((v) => v.toJson()).toList();
    }
    data['hash'] = this.hash;
    return data;
  }
}

class Validity {
  String notBefore;
  String notAfter;

  Validity({this.notBefore, this.notAfter});

  Validity.fromJson(Map<String, dynamic> json) {
    notBefore = json['notBefore'];
    notAfter = json['notAfter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notBefore'] = this.notBefore;
    data['notAfter'] = this.notAfter;
    return data;
  }
}
