#!/bin/bash

# Exit on first error
set -e
# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Grab the file names of the keystore keys
ORG1KEY="$(ls composer/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/)"
ORG2KEY="$(ls composer/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/)"
CERT-0="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt)"
CERT-1="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt)"
CERT-2="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt)"
echo
# check that the composer command exists at a version >v0.14
if hash composer 2>/dev/null; then
    composer --version | awk -F. '{if ($2<15) exit 1}'
    if [ $? -eq 1 ]; then
        echo 'Sorry, Use createConnectionProfile for versions before v0.15.0' 
        exit 1
    else
        echo Using composer-cli at $(composer --version)
    fi
else
    echo 'Need to have composer-cli installed at v0.15 or greater'
    exit 1
fi
# need to get the certificate

cat << EOF > org1connection.json
{
    "name": "byfn-network-org1",
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "mychannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer2.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer2.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com",
                "peer1.org1.example.com",
		        "peer2.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.org1.example.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.example.com",
                "peer1.org2.example.com",
                "peer2.org2.example.com"
            ],
            "certificateAuthorities": [
                "ca.org2.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpcs://{IP-HOST-1}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-O}"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpcs://{IP-HOST-1}:7051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-1}"
            }
        },
        "peer1.org1.example.com": {
            "url": "grpcs://{IP-HOST-1}:8051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-1}"
            }
        },
        "peer2.org1.example.com": {
            "url": "grpcs://{IP-HOST-1}:9051",
            "grpcOptions": {
                "ssl-target-name-override": "peer2.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-1}"
            }
        },
        "peer0.org2.example.com": {
            "url": "grpcs://{IP-HOST-2}:10051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-2}"
            }
        },
        "peer1.org2.example.com": {
            "url": "grpcs://{IP-HOST-2}:11051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-2}"
            }
        },
        "peer2.org2.example.com": {
            "url": "grpcs://{IP-HOST-2}:12051",
            "grpcOptions": {
                "ssl-target-name-override": "peer2.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-2}"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "https://{IP-HOST-1}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.example.com": {
            "url": "https://{IP-HOST-2}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

cat << EOF > org2connection.json
{
    "name": "byfn-network-org2",
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "mychannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer2.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer2.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com",
                "peer1.org1.example.com",
		        "peer2.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.org1.example.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.example.com",
                "peer1.org2.example.com",
                "peer2.org2.example.com"
            ],
            "certificateAuthorities": [
                "ca.org2.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpcs://{IP-HOST-1}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-O}"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpcs://{IP-HOST-1}:7051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-1}"
            }
        },
        "peer1.org1.example.com": {
            "url": "grpcs://{IP-HOST-1}:8051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-1}"
            }
        },
        "peer2.org1.example.com": {
            "url": "grpcs://{IP-HOST-1}:9051",
            "grpcOptions": {
                "ssl-target-name-override": "peer2.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-1}"
            }
        },
        "peer0.org2.example.com": {
            "url": "grpcs://{IP-HOST-2}:10051",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-2}"
            }
        },
        "peer1.org2.example.com": {
            "url": "grpcs://{IP-HOST-2}:11051",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-2}"
            }
        },
        "peer2.org2.example.com": {
            "url": "grpcs://{IP-HOST-2}:12051",
            "grpcOptions": {
                "ssl-target-name-override": "peer2.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "${CERT-2}"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "https://{IP-HOST-1}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.example.com": {
            "url": "https://{IP-HOST-2}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF
PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/"${ORG1KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem

if composer card list -c @byfn-network-org1 > /dev/null; then
    composer card delete -c @byfn-network-org1
fi

composer card create -p org1connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org1.card
composer card import --file /tmp/PeerAdmin@byfn-network-org1.card

PRIVATE_KEY="${DIR}"/composer/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/"${ORG2KEY}"
CERT="${DIR}"/composer/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem


if composer card list -c @byfn-network-org2 > /dev/null; then
    composer card delete -c @byfn-network-org2
fi

composer card create -p org2connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file /tmp/PeerAdmin@byfn-network-org2.card
composer card import --file /tmp/PeerAdmin@byfn-network-org2.card

echo "Hyperledger Composer PeerAdmin card has been imported"
composer card list

# composer runtime install -c PeerAdmin@byfn-network-org1 -n ehr
# composer runtime install -c PeerAdmin@byfn-network-org2 -n ehr
# composer identity request -c PeerAdmin@byfn-network-org1 -u admin -s adminpw -d alice
# composer identity request -c PeerAdmin@byfn-network-org2 -u admin -s adminpw -d bob
# composer network start -c PeerAdmin@byfn-network-org1 -a trade-network.bna -o endorsementPolicyFile=endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem
# composer card create -p org1connection.json -u alice -n trade-network -c alice/admin-pub.pem -k alice/admin-priv.pem
# composer card import -f alice@trade-network.card
# composer card create -p org2connection.json -u bob -n trade-network -c bob/admin-pub.pem -k bob/admin-priv.pem
# composer card import -f bob@trade-network.card

