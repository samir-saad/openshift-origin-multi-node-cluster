
@echo off
title OpenShift Local Cluster

set command=%1
set parallel=%2

IF /i "%command%"=="init" goto clusterInit
IF /i "%command%"=="up" goto clusterUp
IF /i "%command%"=="down" goto clusterDown

echo Argument doesn't match init, up, or down.
goto commonexit

:clusterInit
echo Initialize Cluster
IF "%parallel%" == "parallel" (
    echo Parallel Node Initialization.
	vagrant up --parallel master infra node1 node2 
) ELSE (
    echo Sequential Node Initialization.
	vagrant up master
	vagrant up infra
	vagrant up node1
	vagrant up node2
)
vagrant up toolbox
goto commonexit

:clusterUp
echo Cluster Up
vagrant up toolbox
IF "%parallel%" == "parallel" (
    echo Parallel Node Start.
	vagrant up --parallel infra node1 node2
) ELSE (
    echo Sequential Node Start.
	vagrant up infra
	vagrant up node1
	vagrant up node2
)
vagrant up master
goto commonexit

:clusterDown
echo Cluster Down
vagrant halt master
vagrant halt infra
vagrant halt node1
vagrant halt node2
vagrant halt toolbox
goto commonexit

:commonexit
