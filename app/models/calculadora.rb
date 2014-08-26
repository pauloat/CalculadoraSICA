# horas nocturnas SICA
require 'chronic'
 
class Calculadora
  JORNADA = 31500
  H12 = 2592000
 

  attr_accessor :entradas, :salidas
 
  def initialize(entradas = [], salidas = [])
    @entradas = entradas.collect { |e| e.to_time }
    @salidas = salidas.collect { |s| s.to_time }
  end

  def am_4(entrada)
    entrada.beginning_of_day + 4.hours
  end

  def pm_9(salida)
    salida.beginning_of_day + 21.hours
  end

  def entrada_amanecer(entrada)
    hora_nocturna am_4(entradas[n]) - entrada
  end
 
  def salida_anochecer(salida)
    hora_nocturna salida - pm_9(salidas[n])
  end
 
  # tiempo es cantidad de segundos a convertir
  def hora_nocturna(tiempo)
    (tiempo / 50) * 60
  end
 
  def calcular(n)
    
    if entradas[n] < am_4(entradas[n])
      tiempo_amanecer = (am_4(entradas[n]) - entradas[n])
      tiempo_extra_entrada = entrada_amanecer(entradas[n]) - tiempo_amanecer
    else
      tiempo_extra_entrada = 0
    end

    if salidas[n] > pm_9(salidas[n])
      tiempo_anochecer = (salidas[n] - pm_9(salidas[n]))
      tiempo_extra_salida = salida_anochecer(salidas[n]) - tiempo_anochecer
    else
      tiempo_extra_salida = 0
    end
  
    if entradas[n] >= pm_9(salidas[n]) && salidas[n] <= am_4(entradas[n])
      tiempo_extra_entrada = 0
      tiempo_extra_salida = 0
      jornada_nocturna = (salidas[n] - entradas[n])
      tiempo_extra_nocturno = hora_nocturna(jornada_nocturna) - jornada_nocturna
    elsif entradas[n] >= pm_9(salidas[n]) && salidas[n] > am_4(entradas[n])
      tiempo_extra_entrada = 0
      tiempo_extra_salida = 0
      jornada_nocturna = (am_4(entradas[n]) - entradas[n])
      tiempo_extra_nocturno = hora_nocturna(jornada_nocturna) - jornada_nocturna
    else
      tiempo_extra_nocturno = 0
    end
 
    tiempo_trabajado1 = (((salidas[n].to_f - entradas[n].to_f) + tiempo_extra_entrada + tiempo_extra_salida + tiempo_extra_nocturno ))
  
    if tiempo_trabajado1 > JORNADA
      tiempo_extra = tiempo_trabajado1 - JORNADA
    else
      tiempo_extra = 0
    end

    return Time.at(tiempo_extra).utc.strftime("%H:%M")

#    def enganche(salida1, entrada2)
#      descanso = entrada2 - salida1
#      if descanso < H12
#        horas_enganche = ((H12 - descanso).to_f) / 60 / 60
#      else
#        horas_enganche = 0
#      end
#    end
 
  end
end
