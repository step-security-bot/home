local lib = import 'gmailctl.libsonnet';

local toMe = {
  or: [
    { to: 'vdemeest@redhat.com' },
    { to: 'vdemeester@redhat.com' },
    { to: 'vincent@sbr.pm' },
  ],
};
local label_archive(filter, label) =
   [
    {
      filter: filter,
      actions: {
        archive: true,
        markSpam: false,
        labels: [ label ]
      }
    }
   ]
;

local rh_mailing_list(name, label = '') =
    local labels =
        if label == '' then
           [ std.join('/', std.splitLimit(name, '-', 1) ) ]
        else
           [ label ]
    ;

    [
        {
          filter: {
            and: [
              { list: name + '.redhat.com' },
            ],
          },
          actions: {
            archive: false,
            markSpam: false,
            labels: labels
          }
        },
        {
          filter: {
            and: [
              { list: name + '.redhat.com' },
              { to: '-me' },
            ],
          },
          actions: {
            archive: true,
            markSpam: false,
            labels: labels
          }
        }
    ]
;

{
  version: "v1alpha3",
  author: {
    name: "Vincent Demeester",
    email: "vdemeest@redhat.com"
  },
  // Note: labels management is optional. If you prefer to use the
  // GMail interface to add and remove labels, you can safely remove
  // this section of the config.
  rules: rh_mailing_list('memo-list', 'list/memo') +
    rh_mailing_list('announce-list', 'announce') +
    rh_mailing_list('aos-announce') +
    rh_mailing_list('aos-devel') +
    rh_mailing_list('aos-int-services') +
    rh_mailing_list('aos-logging') +
    rh_mailing_list('cloud-strategy', 'area/cloud-strategy') +
    rh_mailing_list('france-list', 'local/france') +
    rh_mailing_list('france-associates', 'local/france') +
    rh_mailing_list('cdg', 'local/fance/cdg') +
    rh_mailing_list('emea-announce', 'announce/emea') +
    rh_mailing_list('eng-common-logging', 'aos/eng-common-logging') +
    rh_mailing_list('insights-dev') +
    rh_mailing_list('insights-platform') +
    rh_mailing_list('managers-announce') +
    rh_mailing_list('managers-list', 'managers/managers-list') +
    rh_mailing_list('memo-list', 'memo-list') +
    rh_mailing_list('monitoring', 'monitoring') +
    rh_mailing_list('openshift-announce', 'aos/openshift-announce') +
    rh_mailing_list('openshift-sme', 'aos/openshift-sme') +
    rh_mailing_list('pnt-managers', 'managers/pnt-managers') +
    rh_mailing_list('prod-dept', 'pnt/prod-dept') +
    rh_mailing_list('remote-announce', 'announce/remote') +
    rh_mailing_list('remotees-list', 'local/remotees') +
    rh_mailing_list('rh-openstack-announce', 'pnt/rh-openstack-announce') +
    rh_mailing_list('summitdemo2019', 'pnt/summitdemo2019') +
    rh_mailing_list('tech-talk-announce', 'announce/tech-talk') +
    rh_mailing_list('technical-users-list', 'technical-users') +
    rh_mailing_list('upshift', 'psi') +
    rh_mailing_list('usa-announce', 'announce/usa') +
    rh_mailing_list('all-sales', 'sales') +
    rh_mailing_list('devtools-build') +
    rh_mailing_list('devtools-deploy') +
    rh_mailing_list('devtools-lead') +
    rh_mailing_list('devtools-saas') +
    rh_mailing_list('devtools-pm') +
    rh_mailing_list('devtools-architects') +
    rh_mailing_list('devtools-team', 'devtools') +
    rh_mailing_list('devx', 'devtools/devx') +
    rh_mailing_list('serverless-interests', 'project/serverless') +
    rh_mailing_list('serverless-dev', 'project/serverless/dev') +
    rh_mailing_list('pipelines-interests', 'pipelines/serverless') +
    rh_mailing_list('pipelines-dev', 'project/pipelines/dev') +
    label_archive({from: 'do-not-reply@trello.com'}, '_tracker/trello') +
    label_archive({from: 'help-ops@redhat.com'}, '_tracker/rh_service_now') +
    label_archive({from: 'hss-jira@redhat.com'}, '_tracker/jira') +
    label_archive({from: 'jira@jira.prod.coreos.systems'}, '_tracker/jira') +
    label_archive({from: 'kundenservice@egencia.de'}, '_tracker/egencia') +
    label_archive({from: 'people-helpdesk@redhat.com'}, '_tracker/rh_service_now') +
    label_archive({from: 'redhat@service-now.com'}, '_tracker/rh_service_now') +
    label_archive({from: 'workflow@redhat.com'}, '_tracker/ebs_workflow') +
    label_archive({from: 'orangehrmlive.com'}, '_tracker/orange') +
    label_archive({from: 'concursolutions.com'}, '_tracker/concur') +
    label_archive({from: 'errata@redhat.com'}, '_tracker/errata') +
    label_archive({from: 'builds@travis-ci.com'}, '_build/travis') +
    label_archive({from: 'cvp-opts@redhat.com'}, '_build/cvp') +
    label_archive({from: 'buildsys@redhat.com'}, '_build/buildsys') +
    rh_mailing_list('bugzilla', '_tracker/bz') +
  [
    {
      filter: {
        query: "list:(\u003cknative-dev.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "project/knative"
        ]
      }
    },
    {
      filter: {
        query: "list:(devtools-build.redhat.com)"
      },
      actions: {
        labels: [
          "list/devtools/lead"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003cistio-dev.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "project/istio"
        ]
      }
    },
    {
      filter: {
        query: "list:(*.github.com)"
      },
      actions: {
        archive: true,
        markRead: true,
        labels: [
          "area/github"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003cistio-users.googlegroups.com\u003e)"
      },
      actions: {
        archive: true,
        labels: [
          "project/istio"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003cknative-users.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "project/knative"
        ]
      }
    },
    {
      filter: {
        from: "noreply-cloud@google.com"
      },
      actions: {
        labels: [
          "cloud/google"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003ctekton-code-of-conduct.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "project/tekton"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003ckubernetes-sig-cli.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "project/kubernetes/sig-cli"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003ctekton-dev.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "project/tekton"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003coperator-framework.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "area/operators"
        ]
      }
    },
    {
      filter: {
        to: "tekton-governance@googlegroups.com"
      },
      actions: {
        labels: [
          "project/tekton"
        ]
      }
    },
    {
      filter: {
        from: "customercare@ecompanystore.com"
      },
      actions: {
        labels: [
          "area/order"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003ctechnical-users-list.redhat.com\u003e)"
      },
      actions: {
        labels: [
          "list/technical-users"
        ]
      }
    },
    {
      filter: {
        query: "list:(\u003cgoogle-summer-of-code-mentors-list.googlegroups.com\u003e)"
      },
      actions: {
        labels: [
          "group/gsoc"
        ]
      }
    }
  ],
  labels: [
    {
      name: "project/tekton",
      color: {
        background: "#16a765",
        text: "#ffffff"
      }
    },
    {
      name: "area/admin",
      color: {
        background: "#98d7e4",
        text: "#0d3b44"
      }
    },
    {
      name: "project/moby",
      color: {
        background: "#000000",
        text: "#ffffff"
      }
    },
    {
      name: "area/ce"
    },
    {
      name: "area/order"
    },
    {
      name: "project/cdf"
    },
    {
      name: "project/istio",
      color: {
        background: "#b6cff5",
        text: "#0d3472"
      }
    },
    {
      name: "event/kubecon",
      color: {
        background: "#b99aff",
        text: "#ffffff"
      }
    },
    {
      name: "project/knative",
      color: {
        background: "#4986e7",
        text: "#ffffff"
      }
    },
    {
      name: "status/waiting",
      color: {
        background: "#f2b2a8",
        text: "#8a1c0a"
      }
    },
    {
      name: "area/interview",
      color: {
        background: "#000000",
        text: "#ffffff"
      }
    },
    {
      name: "project/ocf",
      color: {
        background: "#b3efd3",
        text: "#0b4f30"
      }
    },
    {
      name: "event/redhat-summit",
      color: {
        background: "#fb4c2f",
        text: "#ffffff"
      }
    },
    {
      name: "area/training",
      color: {
        background: "#ffdeb5",
        text: "#7a4706"
      }
    },
    {
      name: "project/docker",
      color: {
        background: "#b6cff5",
        text: "#0d3472"
      }
    },
    {
      name: "area/learn",
      color: {
        background: "#e3d7ff",
        text: "#3d188e"
      }
    },
    {
      name: "project/kubernetes",
      color: {
        background: "#4986e7",
        text: "#ffffff"
      }
    },
    {
      name: "area/health"
    },
    {
      name: "project/openshift-pipelines",
      color: {
        background: "#b99aff",
        text: "#ffffff"
      }
    },
    {
      name: "area/expense",
      color: {
        background: "#ffc8af",
        text: "#7a2e0b"
      }
    },
    {
      name: "area/opensource",
      color: {
        background: "#b3efd3",
        text: "#0b4f30"
      }
    },
    {
      name: "area/meetup"
    },
    {
      name: "project/kubernetes/sig-cli",
      color: {
        background: "#4986e7",
        text: "#ffffff"
      }
    },
    {
      name: "cloud/google",
      color: {
        background: "#4986e7",
        text: "#ffffff"
      }
    },
    {
      name: "area/conference",
      color: {
        background: "#e3d7ff",
        text: "#3d188e"
      }
    },
    {
      name: "list/technical-users"
    },
    {
      name: "area/operators",
      color: {
        background: "#000000",
        text: "#ffffff"
      }
    },
    {
      name: "area/travel",
      color: {
        background: "#fbe983",
        text: "#594c05"
      }
    },
    {
      name: "group/gsoc",
      color: {
        background: "#4986e7",
        text: "#ffffff"
      }
    },
    {
      name: "area/github",
      color: {
        background: "#000000",
        text: "#ffffff"
      }
    }
  ] + lib.rulesLabels(self.rules),
}
