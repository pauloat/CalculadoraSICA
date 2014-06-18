# horas nocturnas SICA
require 'chronic'
 
class Nocturna
  AM4 = Chronic.parse('4 am')
  PM9 = Chronic.parse('9 pm')
  JORNADA = 525
 
  attr_accessor :entradas, :salidas
 
  def initialize(entradas = [], salidas = [])
    @entradas = entradas
    @salidas = salidas
  end
 
  def entrada_amanecer(entrada)
    hora_nocturna AM4 - entrada
  end
 
  def salida_anochecer(salida)
    hora_nocturna salida - PM9
  end
 
  # tiempo es cantidad de segundos a convertir
  def hora_nocturna(tiempo)
    (tiempo / 50) * 60
  end
 
  def calcular(n)
    
    if entradas[n] < AM4
      tiempo_amanecer = (AM4 - entradas[n])
      tiempo_extra_entrada = entrada_amanecer(entradas[n]) - tiempo_amanecer
    else
      tiempo_extra_entrada = 0
    end

    if salidas[n] > PM9
      tiempo_anochecer = (salidas[n] - PM9)
      tiempo_extra_salida = salida_anochecer(salidas[n]) - tiempo_anochecer
    else
      tiempo_extra_salida = 0
    end
  
    if entradas[n] >= PM9 && salidas[n] <= AM4
      tiempo_extra_entrada = 0
      tiempo_extra_salida = 0
      jornada_nocturna = (salidas[n] - entradas[n])
      tiempo_extra_nocturno = hora_nocturna(jornada_nocturna) - jornada_nocturna
    elsif entradas[n] >= PM9 && salidas[n] > AM4
      tiempo_extra_entrada = 0
      tiempo_extra_salida = 0
      jornada_nocturna = (AM4 - entradas[n])
      tiempo_extra_nocturno = hora_nocturna(jornada_nocturna) - jornada_nocturna
    else
      tiempo_extra_nocturno = 0
    end
 
    tiempo_trabajado1 = (((salidas[n].to_f - entradas[n].to_f) + tiempo_extra_entrada + tiempo_extra_salida + tiempo_extra_nocturno ) / 60)
  
    if tiempo_trabajado1 > JORNADA
      tiempo_extra = tiempo_trabajado1 - JORNADA
    else
      tiempo_extra = 0
    end
 
  end
end