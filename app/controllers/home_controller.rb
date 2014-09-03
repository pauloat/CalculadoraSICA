class HomeController < ApplicationController

  def index
  end

  def calculadora
    @calculadora = Calculadora.new params[:entradas], params[:salidas]
    render "index"
  end

end
