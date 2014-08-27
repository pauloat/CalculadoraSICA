# horas nocturnas SICA
 
class Calculadora
  
  # Public: Duracion en segundos de una jornada. 8h:45m 
  JORNADA = 31500
  
  # Public: Duracion en segundos de 12 hs.
  H12 = 2592000

  attr_accessor :entradas, :salidas
 
  def initialize(entradas = [], salidas = [])
    @entradas = entradas.collect { |e| e.to_time }
    @salidas = salidas.collect { |s| s.to_time }
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
  end

#  def enganche(salida1, entrada2)
#    descanso = entrada2 - salida1
#    if descanso < H12
#      horas_enganche = ((H12 - descanso).to_f) / 60 / 60
#    else
#      horas_enganche = 0
#    end
#  end

  private

  # Internal: Da las 4:00 del dia que se esta calculando
  #
  # entrada - El Datetime del que queremos sacar las 4:00 
  #
  # Examples
  #
  #   am_4(('2014-08-26T08:00').to_time)
  #   # => '2014-08-26 04:00:00 -0300'
  #
  # Return un Time de las 4:00 del dia que se le dio
  def am_4(entrada)
    entrada.beginning_of_day + 4.hours
  end
  
  # Internal: Da las 21:00 del dia que se esta calculando
  #
  # entrada - El Datetime del que queremos sacar las 21:00 
  #
  # Examples
  #
  #   pm_9(('2014-08-26T08:00').to_time)
  #   # => '2014-08-26 21:00:00 -0300'
  # 
  # Return un Time de las 4:00 del dia que se le dio
  def pm_9(salida)
    salida.beginning_of_day + 21.hours
  end

  # Internal: Convierte cada 50 min de hora nocturna (desde las 21 hasta las 4)
  # hora de 60 min.
  #
  # tiempo - Cantidad en segundos a convertir
  #
  # Examples
  #
  #   hora_nocturna(50)
  #   # => '60'
  #
  #   hora_nocturna(2700)
  #   # => '3240'
  #
  # Return el tiempo de hora nocturna regularizado a hora comun
  def hora_nocturna(tiempo)
    (tiempo / 50) * 60
  end

  # Internal: convierte a hora comun las horas nocturnas hasta las 4:00
  #
  # entrada - El Datetime que queremos calcular cuanto tiempo se trabajo antes de las 4:00
  def entrada_amanecer(entrada)
    hora_nocturna am_4(entrada) - entrada
  end
 
  def salida_anochecer(salida)
    hora_nocturna salida - pm_9(salida)
  end
 
end
