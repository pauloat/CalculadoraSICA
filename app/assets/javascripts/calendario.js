//
//$(function() { ... }); es para retrazar la ejecucion del codigo hasta que la pagina este
//cargada del todo.
//


$(function() {

  $('.calendario').datetimepicker({
    controlType: 'select',
    timeFormat: 'hh:mm tt',
    stepMinute: 5
  });
});
