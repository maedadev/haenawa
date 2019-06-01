json.extract!(build_history,
              :id, :branch_no, :build_no, :device, :created_at, :updated_at,
              :started_at, :finished_at, :result)
