class ConcurrencyConfig < Anyway::Config
  # Integer(Float) truncates fractions; configuration must reject them.
  INTEGER = ->(value) { Integer(value.to_s, 10) }.freeze

  # Keep the environment names recognized by Puma and Solid Queue.
  env_prefix ""
  attr_config rails_max_threads: 3, job_threads: 3, job_concurrency: 1,
    db_pool: 5, queue_db_pool: 10, solid_queue_supervisor_mode: "async"
  coerce_types rails_max_threads: INTEGER, job_threads: INTEGER, job_concurrency: INTEGER,
    db_pool: INTEGER, queue_db_pool: INTEGER

  on_load do
    %i[rails_max_threads job_threads job_concurrency db_pool queue_db_pool].each do |key|
      value = public_send(key)
      raise_validation_error("#{key}: expected a positive integer") unless value.is_a?(Integer) && value.positive?
    end
    unless %w[async fork].include?(solid_queue_supervisor_mode)
      raise_validation_error("solid_queue_supervisor_mode: expected async or fork")
    end
    if solid_queue_supervisor_mode == "async" && job_concurrency != 1
      raise_validation_error("job_concurrency: async supervisor supports one worker; use fork for multiple processes")
    end
    if db_pool < [ rails_max_threads, job_threads ].max
      raise_validation_error("db_pool: must accommodate Puma threads and one worker")
    end
    # Async workers, dispatcher, and supervisor share a pool and need service thread headroom.
    queue_headroom = solid_queue_supervisor_mode == "async" ? 7 : 2
    if queue_db_pool < [ rails_max_threads, job_threads + queue_headroom ].max
      raise_validation_error("queue_db_pool: expected at least max(rails_max_threads, job_threads + #{queue_headroom})")
    end
  end
end
