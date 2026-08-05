export type Cert = {
  name: string;
  status: "Active";
  issued: string;
  expires: string;
  code: string;
};

export type Issuer = {
  issuer: string;
  verify: string;
  verifyUrl: string;
  certs: Cert[];
};

export const certifications: Issuer[] = [
  {
    issuer: "CompTIA",
    verify: "verify.CompTIA.org",
    verifyUrl: "https://verify.comptia.org",
    certs: [
      { name: "A+", status: "Active", issued: "02/07/2024", expires: "01/23/2028", code: "7CD4X4N6CBBQ1E95" },
      { name: "Network+", status: "Active", issued: "08/23/2024", expires: "01/23/2028", code: "4C25PL8RM2VE1LWQ" },
      { name: "Security+", status: "Active", issued: "01/23/2025", expires: "01/23/2028", code: "7JPCL7RY6E111QGM" },
      { name: "Cloud+", status: "Active", issued: "09/11/2025", expires: "09/11/2028", code: "4846667811aa43f9bd0ef365032aecf8" },
    ],
  },
  {
    issuer: "AXELOS",
    verify: "peoplecert.org",
    verifyUrl: "https://www.peoplecert.org",
    certs: [
      { name: "ITIL Foundation Certificate in IT Service Management", status: "Active", issued: "05/27/2024", expires: "05/28/2027", code: "GR671654299MD" },
    ],
  },
  {
    issuer: "Linux Professional Institute",
    verify: "lpi.org",
    verifyUrl: "https://www.lpi.org",
    certs: [
      { name: "Linux Essentials", status: "Active", issued: "02/10/2024", expires: "Does not expire", code: "LPI000631395 / akp4mhyj2k" },
    ],
  },
];
