module Operations
  class AgentsController < Admin::BaseController
    def index
      respond_to do |format|
        format.html { render layout: "operations" }
        format.json do
          traces = AgentTrace.retained.order(id: :desc)
          if params[:before]
            cursor = params.expect(:before)
            return head :bad_request unless cursor.match?(/\A[1-9][0-9]{0,18}\z/)

            return head :bad_request if Integer(cursor) > 9_223_372_036_854_775_807

            traces = traces.where(id: ...Integer(cursor))
          end
          page = traces.limit(AgentTrace::PAGE_SIZE + 1).to_a
          more = page.size > AgentTrace::PAGE_SIZE
          page = page.first(AgentTrace::PAGE_SIZE)
          render json: { version: 1, data: page.map(&:document), next_cursor: more ? page.last.id.to_s : nil }
        end
      end
    end
  end
end
