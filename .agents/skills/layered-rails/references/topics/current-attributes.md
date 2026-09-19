# Контекст запроса и задания

- Current содержит объявленные session и request_id. Контекст исполнения thread-scoped; не добавляй скрытую instance-variable мемоизацию и общие class variables.
- Authentication заполняет Current.session, контроллер — request_id. Политика получает пользователя на HTTP-границе; домену передавай зависимости явно.
- RequestCorrelatedJob переносит request_id, добавляет job_id и сбрасывает HTTP session даже при perform_now. Пользователь в worker задаётся аргументом ID и проверяется заново.
- Любой собственный поток исполняет прикладную работу через Rails.application.executor.wrap и возвращает соединение в пул. Предпочитай штатный worker самостоятельным потокам.
- В тесте используй Current.set с блоком. Проверяй два одновременных задания, ошибку, восстановление внешнего контекста и отсутствие утечки в следующий вызов.

Источники поведения: [app/models/current.rb](../../../../../app/models/current.rb), [app/jobs/concerns/request_correlated_job.rb](../../../../../app/jobs/concerns/request_correlated_job.rb), [test/lib/concurrency_test.rb](../../../../../test/lib/concurrency_test.rb), [test/jobs/request_correlated_job_test.rb](../../../../../test/jobs/request_correlated_job_test.rb).
