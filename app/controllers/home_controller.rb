class HomeController < ApplicationController

  def index
  end

  def calculadora
    nocturna = Nocturna.new params[:entradas], params[:salidas]
    binding.pry
  end

end
