# DEV SETUP

## Synapse Development

Installing prerequisites on Mac OS X:
```
xcode-select --install
sudo easy_install pip
brew install pkg-config libffi
```

clone the git repo into a working directory of your choice:

```
git clone git@github.com:eyetime-international-ltd/synapse.git 
cd synapse
```

Synapse has a number of external dependencies, that are easiest to install using pip and a virtualenv:
```
brew install pipenv
pipenv install
pipenv shell
pip install --upgrade --force "jsonschema>=2.5.1" "frozendict>=1" "unpaddedbase64>=1.1.0" "canonicaljson>=1.1.3" "signedjson>=1.0.0" "pynacl>=1.2.1" "service_identity>=16.0.0" "Twisted>=18.7.0" "treq>=15.1" "pyopenssl>=16.0.0" "pyyaml>=3.11" "pyasn1>=0.1.9" "pyasn1-modules>=0.0.7" "daemonize>=2.3.1" "bcrypt>=3.1.0" "pillow>=3.1.2" "sortedcontainers>=1.4.4" "psutil>=2.0.0" "pymacaroons>=0.13.0" "msgpack>=0.5.0" "phonenumbers>=8.2.0" "six>=1.10" "prometheus_client>=0.0.18,<0.4.0" "attrs>=17.4.0" "netaddr>=0.7.18"
```
This will run a process of downloading and installing all the needed dependencies into a virtual env.

Before you can start Synapse, you will need to generate a configuration file. To do this, run:
```
python -m synapse.app.homeserver \
    --server-name <my.domain.name> \
    --config-path homeserver.yaml \
    --generate-config \
    --report-stats=<[yes|no]>
```
... substituting an appropriate value for --server-name. The server name determines the "domain" part of user-ids for users on your server: these will all be of the format @user:my.domain.name. It also determines how other matrix servers will reach yours for Federation. For a test configuration, set this to the hostname of your server. For a more production-ready setup, you will probably want to specify your domain (example.com) rather than a matrix-specific hostname here (in the same way that your email address is probably user@example.com rather than user@email.example.com) - but doing so may require more advanced setup: see Setting up Federation. Beware that the server name cannot be changed later.

This command will generate you a config file that you can then customise, but it will also generate a set of keys for you. These keys will allow your Home Server to identify itself to other Home Servers, so don't lose or delete them. It would be wise to back them up somewhere safe. (If, for whatever reason, you do need to change your Home Server's keys, you may find that other Home Servers have the old key cached. If you update the signing key, you should change the name of the key in the <server name>.signing.key file (the second word) to something different. See the spec for more information on key management.)

start homeserver:
```
python -B -m synapse.app.homeserver -c homeserver.yaml
```

## PyCharm Integration

* Open project via PyCharm:

* PyCharm -> Preferences -> Project Interpreter -> click on the gear icon (right corner) and select ADD

* Choose the Pipenv Enviroment(on the left side) and choose "Python 3.7/usr/local/bin/python3.7" as Base Interpreter
check "install packages from Pipfile"

* Close Preferences

* In the right corner klick on Edit configuration (drop down menu near the green arrow):

* add new configuration: choose Python and configure it as follows:
```
change Script Path to Module name
Module name:            synapse.app.homeserver
Paramters:              -c homeserver.yaml

Python interpreter:     Pipenv(synapse)
Interpreter options:    -B
Working directory:      <Path of repo>
check Add content roots to PYTHONPATH
check Add source roots to PYTHONPATH
check Emulate terminal in output console
```
now you can run and debug synapse



## Dependencies
```
 "jsonschema>=2.5.1" 
 "frozendict>=1" 
 "unpaddedbase64>=1.1.0" 
 "canonicaljson>=1.1.3" 
 "signedjson>=1.0.0" 
 "pynacl>=1.2.1" 
 "service_identity>=16.0.0" 
 "Twisted>=18.7.0" 
 "treq>=15.1" 
 "pyopenssl>=16.0.0" 
 "pyyaml>=3.11" 
 "pyasn1>=0.1.9" 
 "pyasn1-modules>=0.0.7" 
 "daemonize>=2.3.1" 
 "bcrypt>=3.1.0" 
 "pillow>=3.1.2" 
 "sortedcontainers>=1.4.4"
 "psutil>=2.0.0" 
 "pymacaroons>=0.13.0" 
 "msgpack>=0.5.0" 
 "phonenumbers>=8.2.0" 
 "six>=1.10" 
 "prometheus_client>=0.0.18,<0.4.0" 
 "attrs>=17.4.0" 
 "netaddr>=0.7.18"
```
