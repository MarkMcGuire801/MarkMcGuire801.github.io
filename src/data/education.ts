export type Degree = {
  id: string;
  degree: string;
  status: "In Progress" | "Complete";
  school: string;
  dates: string;
  note?: string;
  achievements?: string[];
  coursework: { name: string; aligned?: string }[];
};

export const education: Degree[] = [
  {
    id: "masters",
    degree: "Master of Science in Cybersecurity and Information Assurance",
    status: "In Progress",
    school: "Western Governors University",
    dates: "Starting July 1, 2026 — Expected December 31, 2027",
    note: "This program has not yet begun. All coursework and associated certifications listed below are planned. Upon enrollment, credit for Security Foundations was granted based on existing CompTIA Network+ and Security+ certifications.",
    coursework: [
      { name: "Security Foundations", aligned: "Exempted via CompTIA Network+ & Security+" },
      { name: "Security Operations", aligned: "CompTIA CySA+" },
      { name: "Governance, Risk, and Compliance" },
      { name: "Hacking Countermeasures and Techniques" },
      { name: "Network Design and Management" },
    ],
  },
  {
    id: "wgu-bs",
    degree: "Bachelor of Science in Network Engineering and Security",
    status: "Complete",
    school: "Western Governors University",
    dates: "Conferred May 14, 2026",
    coursework: [
      { name: "IT Foundations", aligned: "CompTIA A+ Core 1" },
      { name: "IT Applications", aligned: "CompTIA A+ Core 2" },
      { name: "Network and Security Foundations" },
      { name: "Business of IT Applications", aligned: "ITIL Foundation v4" },
      { name: "Web Development Foundations" },
      { name: "Networks", aligned: "CompTIA Network+" },
      { name: "Linux Foundations", aligned: "LPI Linux Essentials" },
      { name: "Network Analytics and Troubleshooting" },
      { name: "Introduction to Cryptography" },
      { name: "Managing Cloud Security" },
      { name: "Network and Security Applications", aligned: "CompTIA Security+" },
      { name: "Scripting and Programming Foundations" },
      { name: "Cloud Applications", aligned: "CompTIA Cloud+" },
      { name: "Internet of Things (IoT) and Infrastructure" },
      { name: "Data Management Foundations" },
      { name: "Telecomm and Wireless Communications" },
      { name: "Version Control" },
      { name: "Software Defined Networking" },
      { name: "Network Automation and Deployment" },
      { name: "Python for IT Automation" },
      { name: "Network Engineering and Security Capstone Project" },
    ],
  },
  {
    id: "uofa-bs",
    degree: "Bachelor of Science in Business Administration",
    status: "Complete",
    school: "University of Arizona — Eller College of Management",
    dates: "Conferred December 16, 2022",
    achievements: [
      "Graduated Cum Laude",
      "Dean's List — Fall 2022",
      "Honorable Mention — Fall 2021",
      "Fall 2021 Eller Business Communications Case Competition Winner",
    ],
    coursework: [
      { name: "Intermediate Accounting for Business Administration Majors" },
      { name: "Business Communication" },
      { name: "Organizational Behavior and Management" },
      { name: "Introduction to HR Management" },
      { name: "Microeconomic Analysis for Business Decisions" },
      { name: "Economic Strategy: Business Decisions" },
      { name: "Use and Managing Information Systems" },
      { name: "Project Management" },
      { name: "Macroeconomics, Global Institutions and Policy" },
      { name: "Innovation Principles and Environment" },
      { name: "Integrative Business Foundations with Ethics" },
      { name: "Basic Operations Management" },
      { name: "Introduction to Finance" },
      { name: "Real Estate Finance and Investment" },
      { name: "Introduction to Marketing" },
      { name: "Marketing Analytics" },
    ],
  },
];
