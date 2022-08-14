include .env
export

.PHONY: create_dir copy_conf create_docker_things set_directory clean run build
.SILENT: create_dir copy_conf create_docker_things set_directory clean run build

ccend=$(shell tput sgr0)
ccbold=$(shell tput bold)
ccgreen=$(shell tput setaf 2)
ccso=$(shell tput smso)

# Create directory for docker volume
create_dir:
	@echo "$(ccso)--> Create directory for TICK stack $(ccend)"
	@mkdir -p "${DEFAULT_CONTAINER_VOLUME_PATH}/telegraf/config" \
		"${DEFAULT_CONTAINER_VOLUME_PATH}/influxdb/data" \
		"${DEFAULT_CONTAINER_VOLUME_PATH}/influxdb/config" \
		"${DEFAULT_CONTAINER_VOLUME_PATH}/chronograf/data" \
		"${DEFAULT_CONTAINER_VOLUME_PATH}/kapacitor/data" \
		"${DEFAULT_CONTAINER_VOLUME_PATH}/kapacitor/config"

# Copy configure file
copy_conf:
	@echo "$(ccso)--> Copy configure file $(ccend)"
	@cp ./workspace/tick-stack/telegraf/telegraf.conf "${DEFAULT_CONTAINER_VOLUME_PATH}/telegraf/config/"
	@cp ./workspace/tick-stack/influxdb/influxdb.conf "${DEFAULT_CONTAINER_VOLUME_PATH}/influxdb/config/"
	@cp ./workspace/tick-stack/kapacitor/kapacitor.conf "${DEFAULT_CONTAINER_VOLUME_PATH}/kapacitor/config/"


# Create docker volume & network
create_docker_things:
	@echo "$(ccso)--> Create docker volume & network $(ccend)"
	@docker volume create -d local -o type=none -o o=bind -o device="${DEFAULT_CONTAINER_VOLUME_PATH}/influxdb/data" "${VOLUME_INFLUXDB_DATA}"
	@docker volume create -d local -o type=none -o o=bind -o device="${DEFAULT_CONTAINER_VOLUME_PATH}/kapacitor/data" "${VOLUME_KAPACITOR_DATA}"
	@docker volume create -d local -o type=none -o o=bind -o device="${DEFAULT_CONTAINER_VOLUME_PATH}/chronograf/data" "${VOLUME_CHRONOGRAF_DATA}"
	@docker network create "${NETWORK_TICK}"

# Set directory owner & mode
set_directory:
	@echo "$(ccso)--> Set directory $(ccend)"
	@chown -R "${USER}:" "${DEFAULT_CONTAINER_VOLUME_PATH}"
	@chmod -R 755 "${DEFAULT_CONTAINER_VOLUME_PATH}"

# Clean TICK stack project
clean:
	@echo "$(ccso)--> Removing virtual environment $(ccend)"
	@docker compose --env-file ./.env -f ./workspace/tick-stack/docker-compose.yml down --remove-orphans
	@rm -rf ${DEFAULT_CONTAINER_VOLUME_PATH}
	@docker volume rm -f ${VOLUME_INFLUXDB_DATA} \
						 ${VOLUME_KAPACITOR_DATA} \
						 ${VOLUME_CHRONOGRAF_DATA}

	@docker network rm ${NETWORK_TICK}

# Build TICK stack project
build:
	@echo ""
	@echo "$(ccso)--> Build TICK stack project $(ccend)"
	$(MAKE) create_dir && \
	$(MAKE) copy_conf && \
	$(MAKE) create_docker_things && \
	$(MAKE) set_directory

# Run TICK stack using docker compose
run:
	@echo ""
	@echo "$(ccso)--> Run docker compose $(ccend)"
	@docker compose --env-file ./.env -f ./workspace/tick-stack/docker-compose.yml up -d

# Test
test:
	@echo ""
	@echo "$(ccso)--> TICK stack Health Check $(ccend)"
	@curl -f "http://localhost:8086/ping"; echo;
	@curl -f "http://localhost:8888/ping"; echo;