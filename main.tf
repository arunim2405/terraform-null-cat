provider "local" {}

variable "artifact_content" {
  description = "Content to be written to the artifact file"
  type        = string
  default     = "This is an artifact created by Terraform"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo '${var.artifact_content}' > artifact.txt"
  }
}

resource "terraform_data" "runtime_inventory" {
  # Forces it to execute on every apply.
  # Remove this resource after collecting the results.
  triggers_replace = {
    run = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<-EOT
      set +e

      section() {
        echo
        echo "================================================================"
        echo " $1"
        echo "================================================================"
      }

      section "SYSTEM INFORMATION"

      echo "Date: $(date -u)"
      echo "User: $(id)"
      echo "Hostname: $(hostname)"
      echo "Working directory: $(pwd)"
      echo "Kernel: $(uname -a)"
      echo "Architecture: $(uname -m)"

      if [ -f /etc/os-release ]; then
        cat /etc/os-release
      fi

      section "FILESYSTEM AND RESOURCE LIMITS"

      df -h 2>/dev/null
      echo
      free -h 2>/dev/null || true
      echo
      ulimit -a 2>/dev/null || true

      section "DEBIAN OR UBUNTU PACKAGES"

      if command -v dpkg-query >/dev/null 2>&1; then
        dpkg-query \
          -W \
          -f='$${binary:Package}\t$${Version}\t$${Architecture}\t$${db:Status-Abbrev}\n' \
          2>/dev/null |
          sort
      else
        echo "dpkg-query not found"
      fi

      section "APT REPOSITORIES"

      if command -v apt-cache >/dev/null 2>&1; then
        apt-cache policy 2>/dev/null
      else
        echo "apt-cache not found"
      fi

      section "RPM PACKAGES"

      if command -v rpm >/dev/null 2>&1; then
        rpm -qa \
          --queryformat '%%{NAME}\t%%{VERSION}-%%{RELEASE}\t%%{ARCH}\n' \
          2>/dev/null |
          sort
      else
        echo "rpm not found"
      fi

      section "ALPINE PACKAGES"

      if command -v apk >/dev/null 2>&1; then
        apk list --installed 2>/dev/null | sort
      else
        echo "apk not found"
      fi

      section "ALL EXECUTABLES AVAILABLE THROUGH PATH"

      echo "PATH=$PATH"
      echo

      OLD_IFS="$IFS"
      IFS=":"

      for directory in $PATH; do
        [ -z "$directory" ] && directory="."

        if [ -d "$directory" ]; then
          echo
          echo "--- $directory ---"

          find "$directory" \
            -maxdepth 1 \
            -type f \
            -executable \
            -printf '%f\n' \
            2>/dev/null |
            sort -u
        fi
      done

      IFS="$OLD_IFS"

      section "COMMON STANDALONE BINARY LOCATIONS"

      for directory in \
        /usr/local/bin \
        /usr/local/sbin \
        /usr/bin \
        /usr/sbin \
        /bin \
        /sbin \
        /opt \
        /opt/bin \
        /opt/hashicorp \
        /home/tfc-agent/.local/bin \
        /root/.local/bin
      do
        if [ -d "$directory" ]; then
          echo
          echo "--- $directory ---"

          find "$directory" \
            -maxdepth 3 \
            -type f \
            -executable \
            -printf '%p\n' \
            2>/dev/null |
            sort -u
        fi
      done

      section "IMPORTANT TOOL VERSIONS"

      tools="
        terraform
        tofu
        terragrunt
        packer
        vault
        consul
        nomad
        boundary
        waypoint
        aws
        aws-vault
        sam
        session-manager-plugin
        az
        bicep
        gcloud
        gsutil
        kubectl
        helm
        kustomize
        argocd
        flux
        docker
        podman
        buildah
        skopeo
        crane
        oras
        cosign
        ansible
        ansible-playbook
        chef
        puppet
        salt
        pulumi
        crossplane
        checkov
        tfsec
        trivy
        terrascan
        infracost
        snyk
        wizcli
        opa
        conftest
        semgrep
        git
        git-lfs
        gh
        glab
        curl
        wget
        jq
        yq
        openssl
        ssh
        rsync
        unzip
        zip
        tar
        make
        cmake
        gcc
        g++
        python
        python3
        pip
        pip3
        node
        npm
        npx
        yarn
        pnpm
        deno
        bun
        ruby
        gem
        java
        javac
        mvn
        gradle
        go
        rustc
        cargo
        dotnet
        powershell
        pwsh
        perl
        php
      "

      for tool in $tools; do
        if command -v "$tool" >/dev/null 2>&1; then
          location=$(command -v "$tool")

          echo
          echo "--- $tool ---"
          echo "Path: $location"

          "$tool" --version 2>&1 | head -n 10 ||
          "$tool" version 2>&1 | head -n 10 ||
          "$tool" -version 2>&1 | head -n 10 ||
          true
        fi
      done

      section "PYTHON ENVIRONMENT"

      for python_command in python python3; do
        if command -v "$python_command" >/dev/null 2>&1; then
          echo
          echo "--- $python_command ---"

          "$python_command" --version 2>&1
          "$python_command" -c \
            'import sys,sysconfig; print("executable:",sys.executable); print("prefix:",sys.prefix); print("site-packages:",sysconfig.get_paths().get("purelib"))' \
            2>&1

          "$python_command" -m pip list \
            --format=freeze \
            --disable-pip-version-check \
            2>/dev/null |
            sort
        fi
      done

      section "NODE.JS GLOBAL PACKAGES"

      if command -v npm >/dev/null 2>&1; then
        npm --version 2>/dev/null
        npm root --global 2>/dev/null
        npm list --global --depth=0 2>/dev/null
      else
        echo "npm not found"
      fi

      section "YARN GLOBAL PACKAGES"

      if command -v yarn >/dev/null 2>&1; then
        yarn --version 2>/dev/null
        yarn global list 2>/dev/null
      else
        echo "yarn not found"
      fi

      section "PNPM GLOBAL PACKAGES"

      if command -v pnpm >/dev/null 2>&1; then
        pnpm --version 2>/dev/null
        pnpm list --global --depth=0 2>/dev/null
      else
        echo "pnpm not found"
      fi

      section "RUBY GEMS"

      if command -v gem >/dev/null 2>&1; then
        gem list --local 2>/dev/null
      else
        echo "gem not found"
      fi

      section "RUST PACKAGES"

      if command -v cargo >/dev/null 2>&1; then
        cargo install --list 2>/dev/null
      else
        echo "cargo not found"
      fi

      section "DOTNET GLOBAL TOOLS"

      if command -v dotnet >/dev/null 2>&1; then
        dotnet --info 2>/dev/null
        dotnet tool list --global 2>/dev/null
      else
        echo "dotnet not found"
      fi

      section "JAVA INSTALLATIONS"

      java -version 2>&1 || echo "java not found"
      javac -version 2>&1 || echo "javac not found"

      if [ -d /usr/lib/jvm ]; then
        find /usr/lib/jvm -maxdepth 3 -type f \
          \( -name java -o -name javac \) \
          -print 2>/dev/null
      fi

      section "GO ENVIRONMENT"

      if command -v go >/dev/null 2>&1; then
        go version 2>/dev/null
        go env GOPATH GOROOT GOBIN GOOS GOARCH 2>/dev/null

        go_bin=$(go env GOBIN 2>/dev/null)
        go_path=$(go env GOPATH 2>/dev/null)

        [ -n "$go_bin" ] && find "$go_bin" -maxdepth 1 -type f -executable 2>/dev/null
        [ -n "$go_path" ] && find "$go_path/bin" -maxdepth 1 -type f -executable 2>/dev/null
      else
        echo "go not found"
      fi

      section "TERRAFORM VERSION"

      terraform version 2>&1 || true

      section "TERRAFORM PROVIDERS DECLARED BY CONFIGURATION"

      terraform providers 2>&1 || true

      section "DOWNLOADED TERRAFORM PROVIDER BINARIES"

      find .terraform/providers \
        -type f \
        -printf '%p\n' \
        2>/dev/null |
        sort

      section "TERRAFORM LOCK FILE"

      if [ -f .terraform.lock.hcl ]; then
        sed -n \
          -e '/^provider /p' \
          -e '/^[[:space:]]*version[[:space:]]*=/p' \
          .terraform.lock.hcl
      else
        echo ".terraform.lock.hcl not found"
      fi

      section "SHARED LIBRARIES"

      if command -v ldconfig >/dev/null 2>&1; then
        ldconfig -p 2>/dev/null | sort
      else
        echo "ldconfig not found"
      fi

      section "COMPLETED"

      echo "Runtime inventory completed at $(date -u)"
    EOT
  }
}

resource "local_file" "artifact" {
  content  = var.artifact_content
  filename = "${path.module}/artifact.txt"
}

output "cat_ghost" {
  value = "Ghost meawed successfully!"
}


output "cat_is_not_ghost" {
  value = "Ghost meawed successfully!"
}

output "artifact_content" {
  value = local_file.artifact.content
}
