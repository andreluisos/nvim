local DOCKER_COMPOSE_FILETYPE = "yaml.docker-compose"

vim.filetype.add({
  filename = {
    ["compose.yaml"] = DOCKER_COMPOSE_FILETYPE,
    ["compose.yml"] = DOCKER_COMPOSE_FILETYPE,
    ["docker-compose.yaml"] = DOCKER_COMPOSE_FILETYPE,
    ["docker-compose.yml"] = DOCKER_COMPOSE_FILETYPE,
  },
})
