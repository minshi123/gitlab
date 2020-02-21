export const findings = [
  {
    id: null,
    report_type: 'sast',
    name: 'URLConnection Server-Side Request Forgery (SSRF) and File Disclosure',
    severity: 'medium',
    confidence: 'high',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'URLCONNECTION_SSRF_FD',
        name: 'Find Security Bugs-URLCONNECTION_SSRF_FD',
        url: 'https://find-sec-bugs.github.io/bugs.htm#URLCONNECTION_SSRF_FD',
      },
      {
        external_type: 'cwe',
        external_id: '918',
        name: 'CWE-918',
        url: 'https://cwe.mitre.org/data/definitions/918.html',
      },
    ],
    project_fingerprint: '63baf790952a1522273edf2846dfb7f6e29b5bca',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description:
      'This web server request could be used by an attacker to expose internal services and filesystem.',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 96,
      end_line: 96,
      class: 'com.gitlab.vulnlib.cwe918',
      method: 'vulnID00001',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L96-96',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Spring CSRF unrestricted RequestMapping',
    severity: 'medium',
    confidence: 'high',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'SPRING_CSRF_UNRESTRICTED_REQUEST_MAPPING',
        name: 'Find Security Bugs-SPRING_CSRF_UNRESTRICTED_REQUEST_MAPPING',
        url: 'https://find-sec-bugs.github.io/bugs.htm#SPRING_CSRF_UNRESTRICTED_REQUEST_MAPPING',
      },
      {
        external_type: 'cwe',
        external_id: '352',
        name: 'CWE-352',
        url: 'https://cwe.mitre.org/data/definitions/352.html',
      },
    ],
    project_fingerprint: '49842b9f4bbe1afe74b187fba6216eb4ea5e30a7',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description: "Unrestricted Spring's RequestMapping makes the method vulnerable to CSRF attacks",
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/configuration/HomeController.java',
      start_line: 15,
      end_line: 15,
      class: 'org.openapitools.configuration.HomeController',
      method: 'index',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/configuration/HomeController.java#L15-15',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Potential Path Traversal (file read)',
    severity: 'medium',
    confidence: 'high',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'PATH_TRAVERSAL_IN',
        name: 'Find Security Bugs-PATH_TRAVERSAL_IN',
        url: 'https://find-sec-bugs.github.io/bugs.htm#PATH_TRAVERSAL_IN',
      },
      {
        external_type: 'cwe',
        external_id: '22',
        name: 'CWE-22',
        url: 'https://cwe.mitre.org/data/definitions/22.html',
      },
    ],
    project_fingerprint: '44023b93a1568537bc257d7481a5596b325599da',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description:
      'This API (java/nio/file/Paths.get(Ljava/lang/String;[Ljava/lang/String;)Ljava/nio/file/Path;) reads a file whose location might be specified by user input',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 56,
      end_line: 56,
      class: 'com.gitlab.vulnlib.cwe22',
      method: 'vulnID00001',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L56-56',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'URLConnection Server-Side Request Forgery (SSRF) and File Disclosure',
    severity: 'medium',
    confidence: 'high',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'URLCONNECTION_SSRF_FD',
        name: 'Find Security Bugs-URLCONNECTION_SSRF_FD',
        url: 'https://find-sec-bugs.github.io/bugs.htm#URLCONNECTION_SSRF_FD',
      },
      {
        external_type: 'cwe',
        external_id: '918',
        name: 'CWE-918',
        url: 'https://cwe.mitre.org/data/definitions/918.html',
      },
    ],
    project_fingerprint: '0857addea39feda14055f6d06a8aba814db28c02',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description:
      'This web server request could be used by an attacker to expose internal services and filesystem.',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 116,
      end_line: 116,
      class: 'com.gitlab.vulnlib.cwe918',
      method: 'vulnID00002',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L116-116',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Potential XSS in Servlet',
    severity: 'medium',
    confidence: 'medium',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'XSS_SERVLET',
        name: 'Find Security Bugs-XSS_SERVLET',
        url: 'https://find-sec-bugs.github.io/bugs.htm#XSS_SERVLET',
      },
      {
        external_type: 'cwe',
        external_id: '79',
        name: 'CWE-79',
        url: 'https://cwe.mitre.org/data/definitions/79.html',
      },
    ],
    project_fingerprint: '9da7595ecf96a5ffb9f8d315439533d093cec801',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description:
      'This use of java/io/PrintWriter.print(Ljava/lang/String;)V could be vulnerable to XSS in the Servlet',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/ApiUtil.java',
      start_line: 14,
      end_line: 14,
      class: 'org.openapitools.api.ApiUtil',
      method: 'setExampleResponse',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/ApiUtil.java#L14-14',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Found Spring endpoint',
    severity: 'low',
    confidence: 'low',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'SPRING_ENDPOINT',
        name: 'Find Security Bugs-SPRING_ENDPOINT',
        url: 'https://find-sec-bugs.github.io/bugs.htm#SPRING_ENDPOINT',
      },
    ],
    project_fingerprint: '0036fb14b378eb3edf3b9ded751b6a54de6cd3c5',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description: 'org.openapitools.api.CweApi is a Spring endpoint (Controller)',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 76,
      end_line: 76,
      class: 'org.openapitools.api.CweApi',
      method: 'cwe79vid00001',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L76-76',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Found Spring endpoint',
    severity: 'low',
    confidence: 'low',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'SPRING_ENDPOINT',
        name: 'Find Security Bugs-SPRING_ENDPOINT',
        url: 'https://find-sec-bugs.github.io/bugs.htm#SPRING_ENDPOINT',
      },
    ],
    project_fingerprint: '478d88e684e4929e3c8350f01d22ea1de81c764c',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description: 'org.openapitools.api.CweApi is a Spring endpoint (Controller)',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 96,
      end_line: 96,
      class: 'org.openapitools.api.CweApi',
      method: 'cwe918vid00001',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L96-96',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Found Spring endpoint',
    severity: 'low',
    confidence: 'low',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'SPRING_ENDPOINT',
        name: 'Find Security Bugs-SPRING_ENDPOINT',
        url: 'https://find-sec-bugs.github.io/bugs.htm#SPRING_ENDPOINT',
      },
    ],
    project_fingerprint: 'ae73233c6387cd71e37db995a0a04871c9265ed7',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description: 'org.openapitools.api.CweApi is a Spring endpoint (Controller)',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 56,
      end_line: 56,
      class: 'org.openapitools.api.CweApi',
      method: 'cwe22vid00001',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L56-56',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Found Spring endpoint',
    severity: 'low',
    confidence: 'low',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'SPRING_ENDPOINT',
        name: 'Find Security Bugs-SPRING_ENDPOINT',
        url: 'https://find-sec-bugs.github.io/bugs.htm#SPRING_ENDPOINT',
      },
    ],
    project_fingerprint: 'a93b9ad79f43d665887fee1ebfcd42b722561f6d',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description: 'org.openapitools.api.CweApi is a Spring endpoint (Controller)',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/CweApi.java',
      start_line: 116,
      end_line: 116,
      class: 'org.openapitools.api.CweApi',
      method: 'cwe918vid00002',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/CweApi.java#L116-116',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Potential HTTP Response Splitting',
    severity: 'low',
    confidence: 'low',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'HTTP_RESPONSE_SPLITTING',
        name: 'Find Security Bugs-HTTP_RESPONSE_SPLITTING',
        url: 'https://find-sec-bugs.github.io/bugs.htm#HTTP_RESPONSE_SPLITTING',
      },
      {
        external_type: 'cwe',
        external_id: '113',
        name: 'CWE-113',
        url: 'https://cwe.mitre.org/data/definitions/113.html',
      },
    ],
    project_fingerprint: '202004b1ebb394a41c5d1d6cc5f9832cb7d1561d',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description:
      'This use of javax/servlet/http/HttpServletResponse.addHeader(Ljava/lang/String;Ljava/lang/String;)V might be used to include CRLF characters into HTTP headers',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/api/ApiUtil.java',
      start_line: 13,
      end_line: 13,
      class: 'org.openapitools.api.ApiUtil',
      method: 'setExampleResponse',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/api/ApiUtil.java#L13-13',
  },
  {
    id: null,
    report_type: 'sast',
    name: 'Found Spring endpoint',
    severity: 'low',
    confidence: 'low',
    scanner: { external_id: 'find_sec_bugs', name: 'Find Security Bugs' },
    identifiers: [
      {
        external_type: 'find_sec_bugs_type',
        external_id: 'SPRING_ENDPOINT',
        name: 'Find Security Bugs-SPRING_ENDPOINT',
        url: 'https://find-sec-bugs.github.io/bugs.htm#SPRING_ENDPOINT',
      },
    ],
    project_fingerprint: 'd124ac04928e7809ebabb3f365456df56b404572',
    create_vulnerability_feedback_issue_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_merge_request_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    create_vulnerability_feedback_dismissal_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/vulnerability_feedback',
    project: {
      id: 16819248,
      name: 'java-spring-mvn',
      full_path: '/gitlab-org/security-products/benchmark-suite/java-spring-mvn',
      full_name: 'GitLab.org / security-products / Security Benchmark Suite / java-spring-mvn',
    },
    dismissal_feedback: null,
    issue_feedback: null,
    merge_request_feedback: null,
    description: 'org.openapitools.configuration.HomeController is a Spring endpoint (Controller)',
    links: [],
    location: {
      file: 'src/main/java/org/openapitools/configuration/HomeController.java',
      start_line: 15,
      end_line: 15,
      class: 'org.openapitools.configuration.HomeController',
      method: 'index',
      dependency: { package: {} },
    },
    remediations: [null],
    solution: null,
    state: 'detected',
    blob_path:
      '/gitlab-org/security-products/benchmark-suite/java-spring-mvn/-/blob/a8896bbafbb0beae5e594fae0fd10598b58dfb37/src/main/java/org/openapitools/configuration/HomeController.java#L15-15',
  },
];
