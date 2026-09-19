# Связные Rails concerns

- Concern должен давать одну законченную возможность с понятным host-контрактом; не разрезай модель на modules только по размеру файла.
- Объявляй необходимые методы, callbacks и эффекты в явном месте. Нельзя менять включённые callbacks во время запроса.
- Authentication объединяет жизненный цикл HTTP-сессии; RequestCorrelatedJob — перенос и очистку контекста задания. Эти роли не смешиваются.
- Проверяй concern через реального host и сценарий успеха/ошибки. Для контекста нужны последовательные и конкурентные вызовы без утечки состояния.

Источники поведения: [app/controllers/concerns/authentication.rb](../../../../../app/controllers/concerns/authentication.rb), [app/jobs/concerns/request_correlated_job.rb](../../../../../app/jobs/concerns/request_correlated_job.rb), [test/jobs/request_correlated_job_test.rb](../../../../../test/jobs/request_correlated_job_test.rb).
