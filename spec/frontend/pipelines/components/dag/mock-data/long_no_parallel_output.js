export const nodes = [
  {
    "name": "build_a",
    "size": 1,
    "jobs": [
      {
        "name": "build_a"
      }
    ],
    "category": "build"
  },
  {
    "name": "build_b",
    "size": 1,
    "jobs": [
      {
        "name": "build_b"
      }
    ],
    "category": "build"
  },
  {
    "name": "test_a",
    "size": 1,
    "jobs": [
      {
        "name": "test_a",
        "needs": [
          "build_a"
        ]
      }
    ],
    "category": "test"
  },
  {
    "name": "test_b",
    "size": 1,
    "jobs": [
      {
        "name": "test_b"
      }
    ],
    "category": "test"
  },
  {
    "name": "test_c",
    "size": 1,
    "jobs": [
      {
        "name": "test_c"
      }
    ],
    "category": "test"
  },
  {
    "name": "test_d",
    "size": 1,
    "jobs": [
      {
        "name": "test_d"
      }
    ],
    "category": "test"
  },
  {
    "name": "post_test_a",
    "size": 1,
    "jobs": [
      {
        "name": "post_test_a"
      }
    ],
    "category": "post-test"
  },
  {
    "name": "post_test_b",
    "size": 1,
    "jobs": [
      {
        "name": "post_test_b"
      }
    ],
    "category": "post-test"
  },
  {
    "name": "post_test_c",
    "size": 1,
    "jobs": [
      {
        "name": "post_test_c",
        "needs": [
          "test_a",
          "test_b"
        ]
      }
    ],
    "category": "post-test"
  },
  {
    "name": "staging_a",
    "size": 1,
    "jobs": [
      {
        "name": "staging_a",
        "needs": [
          "post_test_a"
        ]
      }
    ],
    "category": "staging"
  },
  {
    "name": "staging_b",
    "size": 1,
    "jobs": [
      {
        "name": "staging_b",
        "needs": [
          "post_test_b"
        ]
      }
    ],
    "category": "staging"
  },
  {
    "name": "staging_c",
    "size": 1,
    "jobs": [
      {
        "name": "staging_c"
      }
    ],
    "category": "staging"
  },
  {
    "name": "staging_d",
    "size": 1,
    "jobs": [
      {
        "name": "staging_d"
      }
    ],
    "category": "staging"
  },
  {
    "name": "staging_e",
    "size": 1,
    "jobs": [
      {
        "name": "staging_e"
      }
    ],
    "category": "staging"
  },
  {
    "name": "canary_a",
    "size": 1,
    "jobs": [
      {
        "name": "canary_a",
        "needs": [
          "staging_a",
          "staging_b"
        ]
      }
    ],
    "category": "canary"
  },
  {
    "name": "canary_b",
    "size": 1,
    "jobs": [
      {
        "name": "canary_b"
      }
    ],
    "category": "canary"
  },
  {
    "name": "canary_c",
    "size": 1,
    "jobs": [
      {
        "name": "canary_c",
        "needs": [
          "staging_b"
        ]
      }
    ],
    "category": "canary"
  },
  {
    "name": "production_a",
    "size": 1,
    "jobs": [
      {
        "name": "production_a",
        "needs": [
          "canary_a"
        ]
      }
    ],
    "category": "production"
  },
  {
    "name": "production_b",
    "size": 1,
    "jobs": [
      {
        "name": "production_b"
      }
    ],
    "category": "production"
  },
  {
    "name": "production_c",
    "size": 1,
    "jobs": [
      {
        "name": "production_c"
      }
    ],
    "category": "production"
  },
  {
    "name": "production_d",
    "size": 1,
    "jobs": [
      {
        "name": "production_d",
        "needs": [
          "canary_c"
        ]
      }
    ],
    "category": "production"
  }
];

export const nodeDict = {
  "build_a": {
    "name": "build_a",
    "size": 1,
    "jobs": [
      {
        "name": "build_a"
      }
    ],
    "category": "build"
  },
  "build_b": {
    "name": "build_b",
    "size": 1,
    "jobs": [
      {
        "name": "build_b"
      }
    ],
    "category": "build"
  },
  "test_a": {
    "name": "test_a",
    "size": 1,
    "jobs": [
      {
        "name": "test_a",
        "needs": [
          "build_a"
        ]
      }
    ],
    "category": "test"
  },
  "test_b": {
    "name": "test_b",
    "size": 1,
    "jobs": [
      {
        "name": "test_b"
      }
    ],
    "category": "test"
  },
  "test_c": {
    "name": "test_c",
    "size": 1,
    "jobs": [
      {
        "name": "test_c"
      }
    ],
    "category": "test"
  },
  "test_d": {
    "name": "test_d",
    "size": 1,
    "jobs": [
      {
        "name": "test_d"
      }
    ],
    "category": "test"
  },
  "post_test_a": {
    "name": "post_test_a",
    "size": 1,
    "jobs": [
      {
        "name": "post_test_a"
      }
    ],
    "category": "post-test"
  },
  "post_test_b": {
    "name": "post_test_b",
    "size": 1,
    "jobs": [
      {
        "name": "post_test_b"
      }
    ],
    "category": "post-test"
  },
  "post_test_c": {
    "name": "post_test_c",
    "size": 1,
    "jobs": [
      {
        "name": "post_test_c",
        "needs": [
          "test_a",
          "test_b"
        ]
      }
    ],
    "category": "post-test"
  },
  "staging_a": {
    "name": "staging_a",
    "size": 1,
    "jobs": [
      {
        "name": "staging_a",
        "needs": [
          "post_test_a"
        ]
      }
    ],
    "category": "staging"
  },
  "staging_b": {
    "name": "staging_b",
    "size": 1,
    "jobs": [
      {
        "name": "staging_b",
        "needs": [
          "post_test_b"
        ]
      }
    ],
    "category": "staging"
  },
  "staging_c": {
    "name": "staging_c",
    "size": 1,
    "jobs": [
      {
        "name": "staging_c"
      }
    ],
    "category": "staging"
  },
  "staging_d": {
    "name": "staging_d",
    "size": 1,
    "jobs": [
      {
        "name": "staging_d"
      }
    ],
    "category": "staging"
  },
  "staging_e": {
    "name": "staging_e",
    "size": 1,
    "jobs": [
      {
        "name": "staging_e"
      }
    ],
    "category": "staging"
  },
  "canary_a": {
    "name": "canary_a",
    "size": 1,
    "jobs": [
      {
        "name": "canary_a",
        "needs": [
          "staging_a",
          "staging_b"
        ]
      }
    ],
    "category": "canary"
  },
  "canary_b": {
    "name": "canary_b",
    "size": 1,
    "jobs": [
      {
        "name": "canary_b"
      }
    ],
    "category": "canary"
  },
  "canary_c": {
    "name": "canary_c",
    "size": 1,
    "jobs": [
      {
        "name": "canary_c",
        "needs": [
          "staging_b"
        ]
      }
    ],
    "category": "canary"
  },
  "production_a": {
    "name": "production_a",
    "size": 1,
    "jobs": [
      {
        "name": "production_a",
        "needs": [
          "canary_a"
        ]
      }
    ],
    "category": "production"
  },
  "production_b": {
    "name": "production_b",
    "size": 1,
    "jobs": [
      {
        "name": "production_b"
      }
    ],
    "category": "production"
  },
  "production_c": {
    "name": "production_c",
    "size": 1,
    "jobs": [
      {
        "name": "production_c"
      }
    ],
    "category": "production"
  },
  "production_d": {
    "name": "production_d",
    "size": 1,
    "jobs": [
      {
        "name": "production_d",
        "needs": [
          "canary_c"
        ]
      }
    ],
    "category": "production"
  }
};

export const unfilteredLinks = [
  {
    "source": "build_a",
    "target": "test_a",
    "value": 10
  },
  {
    "source": "test_a",
    "target": "post_test_c",
    "value": 10
  },
  {
    "source": "test_b",
    "target": "post_test_c",
    "value": 10
  },
  {
    "source": "post_test_a",
    "target": "staging_a",
    "value": 10
  },
  {
    "source": "post_test_b",
    "target": "staging_b",
    "value": 10
  },
  {
    "source": "staging_a",
    "target": "canary_a",
    "value": 10
  },
  {
    "source": "staging_b",
    "target": "canary_a",
    "value": 10
  },
  {
    "source": "staging_b",
    "target": "canary_c",
    "value": 10
  },
  {
    "source": "canary_a",
    "target": "production_a",
    "value": 10
  },
  {
    "source": "canary_c",
    "target": "production_d",
    "value": 10
  }
];

export const filteredLinks = [
  {
    "source": "build_a",
    "target": "test_a",
    "value": 10
  },
  {
    "source": "test_a",
    "target": "post_test_c",
    "value": 10
  },
  {
    "source": "test_b",
    "target": "post_test_c",
    "value": 10
  },
  {
    "source": "post_test_a",
    "target": "staging_a",
    "value": 10
  },
  {
    "source": "post_test_b",
    "target": "staging_b",
    "value": 10
  },
  {
    "source": "staging_a",
    "target": "canary_a",
    "value": 10
  },
  {
    "source": "staging_b",
    "target": "canary_a",
    "value": 10
  },
  {
    "source": "staging_b",
    "target": "canary_c",
    "value": 10
  },
  {
    "source": "canary_a",
    "target": "production_a",
    "value": 10
  },
  {
    "source": "canary_c",
    "target": "production_d",
    "value": 10
  }
];

// export const links = [];
//
// export const sankeyfied =
