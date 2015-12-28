package{ 'python3-pip':
    ensure   => installed
}

define pip2Packages {
    ensure_resource('package', "p2$name", {name=>$name, ensure=>present, provider=>pip})
}

define pip3Packages {
    ensure_resource('package', "p3$name", {name=>$name, ensure=>present, provider=>pip3, require=>Package['python3-pip']})
}

pip2Packages { concat(hiera('pip::common'), hiera('pip::pip2')): }
pip3Packages { concat(hiera('pip::common'), hiera('pip::pip3')): }

