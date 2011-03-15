class LocalErrorsController < PublicErrorsController
  def diagnostics
    internal_server_error
  end
end