FROM swiftdocker/swift
MAINTAINER watura <watura@g91.org>
LABEL Description="Docker image for try! Swift2017 Hackathon team SwiftScript."


USER root
RUN chmod 644 /usr/lib/swift/CoreFoundation/*
RUN apt-get update; apt-get install -y clang libicu-dev libcurl4-openssl-dev libssl-dev;

RUN mkdir /root/SwiftScriptServer
ADD Sources /root/SwiftScriptServer/Sources
ADD Package.swift /root/SwiftScriptServer

RUN cd /root/SwiftScriptServer && swift build

CMD [ "sh", "-c", "cd /root/SwiftScriptServer/ && .build/debug/SwiftScriptServer" ]

EXPOSE 8080
