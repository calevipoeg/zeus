# frozen_string_literal: true

namespace :docker_service do
  desc 'Update a service'
  task :update, %i[application arguments] do |_t, argv|
    command "docker service update #{argv.application} #{argv.arguments}"
  end

  desc 'Create docker container'
  task :create, %i[arguments] do |_t, argv|
    command "docker service create #{argv.arguments.tr("\n", ' ')}"
  end

  # The <command> should have:
  # 1) "--restart-condition none" and "--detach" arguments for docker-create
  # 2) "--name $SHOT_NAME"
  desc 'Execute one-time container task'
  task :shot, %i[name command] do |_t, argv|
    command <<~CMD
      bash << "EOF"
        export SHOT_NAME=#{argv.name}

        docker service rm $SHOT_NAME 2>/dev/null

        TASK_ID=$(#{argv.command})

        echo "Waiting ${SHOT_NAME} with ID <${TASK_ID}> for being finished"

        while : ; do
          STOPPED_TASK=$(docker service ps --filter 'desired-state=shutdown' ${TASK_ID} -q)
          [[ ${STOPPED_TASK} != "" ]] && break
          echo "not finished yet $(date)"
          sleep 1
        done

        docker service logs --raw ${TASK_ID}
        docker service rm ${TASK_ID} > /dev/null
      EOF
    CMD
  end
end
