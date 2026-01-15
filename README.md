# Dev Scripts - Dockerized Version

This directory contains development scripts that have been updated to work with the new Docker Compose development environment.

## 🔄 Migration from Non-Dockerized to Dockerized

All scripts in this directory have been converted from the old non-dockerized development environment to work with Docker Compose. The scripts now use `docker compose exec` commands instead of running commands directly on the host machine.

## 📋 Available Scripts

### `checkout-pull-install.sh <branch_name>`
Checkout a branch, pull latest changes, and update dependencies.

**Usage:**
```bash
cd ~/ujet/ujet-server  # or ~/ujet/ujet-client
../dev_scripts/checkout-pull-install.sh feature/my-branch
```

**What it does:**
- Checks out the specified branch and pulls latest changes
- For ujet-server: Flushes Redis, runs bundle install, and migrates database
- For ujet-client: Restarts frontend container to pick up dependency changes

---

### `clean_pull.sh [backend_branch] [frontend_branch]`
Clean pull all repositories and rebuild containers with fresh dependencies.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./clean_pull.sh master master
# or
./clean_pull.sh release/3.39  # uses same branch for both
```

**What it does:**
- Hard resets all repositories to specified branches
- Stops all containers
- Flushes Redis
- Removes all node_modules volumes
- Rebuilds and starts all containers
- Runs Rails setup tasks and migrations

---

### `clear-storage.sh`
Clear Docker container logs and cleanup storage.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./clear-storage.sh
```

**What it does:**
- Truncates Docker container logs
- Clears Rails log files in mounted volumes
- Removes unused Docker resources
- Cleans up temporary files and puppeteer profiles
- Shows disk usage before and after cleanup

---

### `git-stash-checkout-pull-pop.sh <branch_name>`
Stash changes, checkout branch, pull, and pop stash.

**Usage:**
```bash
cd ~/ujet/ujet-server  # or any repo
../dev_scripts/git-stash-checkout-pull-pop.sh feature/my-branch
```

**What it does:**
- Stashes current changes
- Checks out and pulls the specified branch
- Pops the stash
- Optionally restarts relevant Docker containers

---

### `init.sh`
Initialize development environment with fresh dependencies.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./init.sh
```

**What it does:**
- Pulls latest changes for ujet-client
- Removes node_modules volumes
- Rebuilds containers for Node.js services
- Runs database migrations

---

### `pull_all.sh [backend_branch] [frontend_branch]`
Pull all repositories and restart containers.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./pull_all.sh master master
```

**What it does:**
- Pulls latest changes for all repositories
- Flushes Redis
- Restarts all containers
- Runs Rails setup tasks and migrations

---

### `reset_db.sh`
Reset database to clean state.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./reset_db.sh
```

**What it does:**
- Drops all databases
- Creates databases
- Loads schema
- Runs migrations with data
- Runs remotedev:setup
- Updates permissions and Firebase rules

---

### `run.sh [be|fe|all]`
Start UJET services.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./run.sh        # Start all services
./run.sh be     # Start backend only
./run.sh fe     # Start frontend only
```

**What it does:**
- Flushes Redis
- Starts specified Docker services
- Shows access URLs and helpful commands

---

### `start_rails_console.sh`
Start Rails console with tenant helpers.

**Usage:**
```bash
cd ~/ujet/dev_scripts
./start_rails_console.sh
```

**What it does:**
- Starts Rails console in Docker container
- Auto-loads tenant helper methods (switchz, switchs, switchk)
- Switches to default tenant (zdcomuhibalhasan)

## 🔑 Key Differences from Old Scripts

### Old (Non-Dockerized)
- Used `bundle install` directly on host
- Used `npm install` with nvm on host
- Used `redis-cli` on host
- Used `mysql` command on host
- Managed processes with PM2 or direct execution

### New (Dockerized)
- Uses `docker compose exec rails-api bundle install`
- Restarts containers to pick up dependency changes
- Uses `docker compose exec redis redis-cli`
- Uses `docker compose exec mysql mysql`
- Manages services with `docker compose up/down/restart`

## 📚 Additional Resources

- [Docker Commands Reference](../ujet-dev-portal/docs/docker_commands.md)
- [Development Guide](../ujet-dev-portal/docs/development_guide.md)
- [Docker Architecture](../ujet-dev-portal/docs/docker_arch.md)
- [Devcontainer Guide](../ujet-dev-portal/docs/devcontainer_guide.md)

## 💡 Tips

1. **Always run scripts from the correct directory** - Most scripts auto-detect the project root, but some work best when run from specific locations.

2. **Use the ujet.sh script** - For most operations, consider using `~/ujet/ujet-dev-portal/scripts/ujet.sh` which provides a comprehensive set of commands.

3. **Check container status** - Use `docker compose ps` to check if containers are running before running scripts.

4. **View logs** - Use `docker compose logs -f <service>` to view real-time logs.

5. **Dependency changes** - When you modify Gemfile or package.json, restart the relevant container to pick up changes.

