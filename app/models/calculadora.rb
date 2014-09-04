class Calculadora

  # Public: Duracion en segundos de una jornada. 8 horas y 45 minutos.
  JORNADA = 31500

  # Public: Duracion en segundos de 12 hs.
  H12 = 43200

  attr_accessor :entradas, :salidas

  def initialize(entradas = [], salidas = [])
    @entradas = entradas.collect { |e| e.to_time }
    @salidas = salidas.collect { |s| s.to_time }
  end

  # Public: Calcula la cantidad de tiempo extra trabajado en una jornada
  #
  # trabajo(n) - Cantidad en segundos de tiempo trabajado.
  #
  # JORNADA    - Constante de 8 horas y 45 minutos en segundos.
  #
  # Examples
  #
  #   extras(42000)
  #   # => "02:55"
  #
  #   extras(20500)
  #   # => "00:00"
  #
  # Return String con la cantidad de horas y minutos extra trabajados.
  def extras(n)
    if entradas[n].nil? || salidas[n].nil?
      tiempo_extra = 0
    elsif trabajo(n) > JORNADA
      tiempo_extra = trabajo(n) - JORNADA
    else
      tiempo_extra = 0
    end

    return Time.at(tiempo_extra).utc.strftime("%H:%M")
  end

  # Public: Suma la cantidad de horas de enganche con las de domingo para
  #         regesar las horas al 100%.
  #
  # enganche(n) - Cantidad en segundos de tiempo trabajado antes que pasen 12
  # horas del fin de la ultima jornada.
  #
  # domingo(n)  - Cantidad en segundos de tiempo trabajado durante dia domingo.
  #
  # Return String con la cantidad de horas y minutos trabajados al 100%.
  #
  def horas_100(n)
    if entradas[n].nil? || salidas[n].nil?
      tiempo_extra_100 = 0
    else
      tiempo_extra_100 = enganche(n) + domingo(n)
    end

    return Time.at(tiempo_extra_100).utc.strftime("%H:%M")

  end

  private

  # Internal: Calula el tiempo que duro el turno de trabajo.
  #
  # entradas[n]           - Horario en Time de la entrada del turno.
  #
  # salidas[n]            - Horario en Time de la salida del turno.
  #
  # am_4()                - Da las 4am del dia que se esta calculando.
  #
  # pm_9()                - Da las 9pm del dia que se esta calculando.
  #
  # tiempo_amanecer       - Cuanto tiempo se trabajo en segundos hasta las 4am
  #
  # tiempo_anochecer      - Cuanto tiempo se trabajo en segundos desde las 9pm
  #
  # tiempo_extra_entrada  - Los segundos extra que se agregan a la entrada por
  #                         el trabajo nocturno antes de las 4am.
  #
  # tiempo_extra_salida   - Los segundos extra que se agregan a la salida por
  #                         el trabajo nocturno despues de las 9pm.
  #
  # tiempo_extra_nocturno - Los segundos extra que se agregan a la jornada
  #                         cuando el comienzo es despues de las 9pm.
  #
  # jornada_nocturna      - Duracion en segundos de la jornada trabajada cuando
  #                         comienza despues de las 9pm.
  #
  # hora_nocturna         - Convierte cada 50 segundos de hora nocturna (desde
  #                         las 21 hasta las 4) a 60 segundos.
  #
  # entrada_amanecer      - Convierte a 60 segundos cada 50 segundos nocturnos
  #                         trabajados hasta las 4am.
  #
  # salida_anochecer      - Convierte a 60 segundos cada 50 segundos nocturnos
  #                         trabajados desde las 9pm.
  #
  # tiempo_trabajado      - Cantidad en segundos trabajados desde la entrada
  #                         hasta la salida sumando el tiempo extra por horario
  #                         nocturno.
  def trabajo(n)

    if entradas[n] < am_4(entradas[n])
      tiempo_amanecer = (am_4(entradas[n]) - entradas[n])
      tiempo_extra_entrada = entrada_amanecer(entradas[n]) - tiempo_amanecer
    else
      tiempo_extra_entrada = 0
    end

    if salidas[n] > pm_9(entradas[n])
      tiempo_anochecer = (salidas[n] - pm_9(entradas[n]))
      tiempo_extra_salida = salida_anochecer(salidas[n]) - tiempo_anochecer
    else
      tiempo_extra_salida = 0
    end

    if entradas[n] >= pm_9(entradas[n]) && salidas[n] <= am_4(entradas[n]) + 24.hours
      tiempo_extra_entrada = 0
      tiempo_extra_salida = 0
      jornada_nocturna = (salidas[n] - entradas[n])
      tiempo_extra_nocturno = hora_nocturna(jornada_nocturna) - jornada_nocturna
    elsif entradas[n] >= pm_9(entradas[n]) && salidas[n] > am_4(entradas[n])
      tiempo_extra_entrada = 0
      tiempo_extra_salida = 0
      jornada_nocturna = (am_4(entradas[n]) - entradas[n])
      tiempo_extra_nocturno = hora_nocturna(jornada_nocturna) - jornada_nocturna
    else
      tiempo_extra_nocturno = 0
    end

   tiempo_trabajado = (((salidas[n].to_f - entradas[n].to_f) + tiempo_extra_entrada + tiempo_extra_salida + tiempo_extra_nocturno))

   return tiempo_trabajado

  end

  # Internal: Calcula la cantidad de horas enganche entre dos jornadas.
  #
  # descanso       - Tiempo en segundos entre la salida de un turno y la entrada
  #                  del siguiente.
  #
  # salidas[n]     - Horario en Time de la salida del turno.
  #
  # entradas[n + 1]  - Horario en Time de la entrada del siguiente turno.
  #
  # H12            - Constante en segundos de 12 horas.
  #
  # horas_enganche - Cantidad de tiempo en segundos del tiempo trabajado menor a
  #                  12 horas.
  #
  # Return la cantidad de horas y minutos trabajados en segundos antes de que
  #   pasen 12 horas desde el fin del ultimo turno.
  def enganche(n)
    if entradas[n].nil? || salidas[n - 1].nil?
      descanso = H12
    else
      descanso = entradas[n] - salidas[n - 1]
    end

    if descanso < H12
      horas_enganche = H12 - descanso
    else
      horas_enganche = 0
    end

    return horas_enganche

  end

  # Internal: Calcula la cantidad de tiempo que se trabajo el domingo.
  #
  # entradas[n]   - Horario en Time de la entrada del turno.
  #
  # salidas[n]    - Horario en Time de la salida del turno.
  #
  # horas_domingo - Cantidad de horas trabajadas durante el domingo.
  #
  # Return la cantidad de horas y minutos trabajados en segundos durante la
  #   jornada de domingo.
  def domingo(n)
    if entradas[n].sunday? && salidas[n].sunday?
      horas_domingo = trabajo(n)
    elsif entradas[n].sunday? && !salidas[n].sunday?
      horas_domingo = trabajo(n) - (salidas[n].beginning_of_day - salidas[n])
    elsif !entradas[n].sunday? && salidas[n].sunday?
      horas_domingo = trabajo(n) - (entradas[n] - entradas[n].beginning_of_day)
    else
      horas_domingo = 0
    end

    return horas_domingo

  end

  # Internal: Da las 4am del dia que se esta calculando.
  #
  # entrada - El Datetime del que queremos sacar las 4am.
  #
  # Examples
  #
  #   am_4(('2014-08-26T08:00').to_time)
  #   # => '2014-08-26 04:00:00 -0300'
  #
  # Return un Time de las 4am del dia que se le dio.
  def am_4(entrada)
    entrada.beginning_of_day + 4.hours
  end

  # Internal: Da las 9pm del dia que se esta calculando.
  #
  # entrada - El Datetime del que queremos sacar las 9pm.
  #
  # Examples
  #
  #   pm_9(('2014-08-26T08:00').to_time)
  #   # => '2014-08-26 21:00:00 -0300'
  #
  # Return un Time de las 9pm del dia que se le dio.
  def pm_9(entrada)
    entrada.beginning_of_day + 21.hours
  end

  # Internal: Convierte cada 50 min de hora nocturna (desde las 21 hasta las 4)
  # en horas de 60 min.
  #
  # tiempo - Cantidad en segundos a convertir.
  #
  # Examples
  #
  #   hora_nocturna(50)
  #   # => '60'
  #
  #   hora_nocturna(2700)
  #   # => '3240'
  #
  # Return el tiempo de hora nocturna regularizado a hora comun.
  def hora_nocturna(tiempo)
    (tiempo / 50) * 60
  end

  # Internal: Convierte a hora comun las horas nocturnas hasta las 4am.
  #
  # entrada - El Datetime que queremos calcular cuanto tiempo se trabajo antes
  #           de las 4am.
  def entrada_amanecer(entrada)
    hora_nocturna am_4(entrada) - entrada
  end

  # Internal: Convierte a hora comun las horas nocturnas desde las 9pm.
  #
  # entrada - El Datetime que queremos calcular cuanto tiempo se trabajo desde
  #           las 9pm.
  def salida_anochecer(entrada)
    hora_nocturna entrada - pm_9(entrada)
  end

end
