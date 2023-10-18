#!/bin/bash

JAR="$XDG_DATA_HOME/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"

java \
	-Declipse.application=org.eclipse.jdt.ls.core.id1 \
	-Dosgi.bundles.defaultStartLevel=4 \
	-Declipse.product=org.eclipse.jdt.ls.core.product \
	-Dlog.protocol=true \
	-Dlog.level=ALL \
	-Xms1g \
	-javaagent:"$XDG_DATA_HOME"/nvim/mason/packages/jdtls/lombok.jar \
	-Xbootclasspath/a:"$XDG_DATA_HOME"/nvim/mason/packages/jdtls/lombok.jar \
	-jar $(echo "$JAR") \
	-configuration "$XDG_DATA_HOME/nvim/mason/packages/jdtls/config_linux" \
	-data "$HOME/workspace/java" \
	--add-modules=ALL-SYSTEM \
	--add-opens java.base/java.util=ALL-UNNAMED \
	--add-opens java.base/java.lang=ALL-UNNAMED
