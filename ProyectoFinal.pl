:- use_module(library(pce)).
:- use_module(library(pce_style_item)).

% Define una variable global para almacenar la ventana actual
:- dynamic current_window/1.

menu:-
    % Cierra la ventana actual si existe
    (retract(current_window(Win)) -> send(Win, destroy) ; true),

    new(D, dialog('BodyFit')),
    new(L1, label(nombre, 'Gimnasio BodyFit')),
    new(L, label(nombre1, 'Bienvenido a nuestro sistema de recomendación de ejercicios')),
    new(B, button('Recomendacion de ejercicios', message(@prolog, principal))),
    send(D, size, size(400, 150)),  % Ajusta el tamaño de la ventana
    send(D, append(L1)),
    send(L1, alignment, center),
    send(D, append(L)),
    send(D, append(B)),
    send(D, append, button('Salir', message(D, destroy))),
    send(D, open),

    % Guarda la ventana actual
    assert(current_window(D)).

principal:-
    % Cierra la ventana actual si existe
    (retract(current_window(Win)) -> send(Win, destroy) ; true),

    new(D, dialog('BodyFit')),
    new(L, label(nombre,'Hola, Aqui tenemos unas opciones para ti :)')),
    new(B, button('Bajar de peso', message(@prolog, ventanal))),
    new(B1, button('Ganancias musculares', message(@prolog, ventana2))),
    send(D, size, size(400, 150)),  % Ajusta el tamaño de la ventana
    send(L, alignment, center),
    send(D, append(L)),
    send(D, append(B)),
    send(D, append(B1)),
    send(D, append, button('Salir', message(D, destroy))),
    send(D, open),

    % Guarda la ventana actual
    assert(current_window(D)).


%Calculo de IMC para recomendar en si bajar de peso o no
calcular_imc(Altura, Peso, IMC) :-
    IMC is Peso / (Altura * Altura).

% Predicado para dar una recomendación según el IMC
recomendacion(IMC, Mensaje) :-
    IMC < 18.5,
    Mensaje = 'Estás por debajo del peso saludable. Deberías consultar a un médico o dietista asi que no es recomendable bajar de peso.'.

recomendacion(IMC, Mensaje) :-
    IMC >= 18.5, IMC < 25,
    Mensaje = 'Estás en un rango de peso saludable. ¡Sigue manteniendo un estilo de vida saludable!, sin descuidar tu alimentacion y ejercicio'.

recomendacion(IMC, Mensaje) :-
    IMC >= 25, IMC < 30,
    Mensaje = 'Tienes sobrepeso. Puede ser beneficioso considerar una dieta saludable y aumentar la actividad física.'.

recomendacion(IMC, Mensaje) :-
    IMC >= 30,
    Mensaje = 'Tienes obesidad. Se recomienda buscar asesoramiento médico o de un dietista y considerar un plan de pérdida de peso.'.

ventanal:-
(retract(current_window(Win)) -> send(Win, destroy) ; true),
    new(D, dialog('Bodyfit')),
    new(L, label(nombre,'Bienvenido aqui calcularemos tu IMC,
    \n Esto es solamente para personas que empiezan a dejar su vida sedentaria')),
    send(D,append(L)),
    send(D, append, new(AlturaTextItem, text_item('Altura (m):'))),
    send(D, append, new(PesoTextItem, text_item('Peso (kg):'))),
    send(D, append, button('Calcular IMC', message(@prolog, calcular_y_mostrar_imc, AlturaTextItem, PesoTextItem))),
    new(B1, button('Regresar', and(message(@prolog, principal)))),
    send(D, append(B1)),
      send(D, open).

% Predicado para calcular el IMC y mostrar una recomendación
calcular_y_mostrar_imc(AlturaTextItem, PesoTextItem) :-
    get(AlturaTextItem, selection, AlturaStr),
    get(PesoTextItem, selection, PesoStr),
    atom_number(AlturaStr, Altura),
    atom_number(PesoStr, Peso),
    calcular_imc(Altura, Peso, IMC),
    recomendacion(IMC, Mensaje),
    mostrar_resultado(IMC, Mensaje).

% Predicado para mostrar el resultado en una nueva ventana
mostrar_resultado(IMC, Mensaje) :-
    new(D, dialog('Resultado de IMC')),
    send(D, append, label(imc_label, 'Tu IMC es:')),
    send(D, append, label(imc_valor, IMC)),
    send(D, append, label(recomendacion_label, 'Recomendación:')),
    send(D, append, label(recomendacion_valor, Mensaje)),
    send(D, append, button('Cerrar', message(D, destroy))),
    send(D, open).

ventana2:-
(retract(current_window(Win)) -> send(Win, destroy) ; true),
new(@mainDialog, dialog('Bodyfit')),
    send(@mainDialog, size, size(400, 200)),  % Ajusta el tamaño de la ventana
    send(@mainDialog, append, new(@input, text_item(usuario, ''))),
    send(@mainDialog, append, new(@objetivo, menu('Objetivo de Entrenamiento', cycle))),
    send(@objetivo, append, 'Pérdida de Peso'),
    send(@objetivo, append, 'Ganancia de Masa Muscular'),
    send(@objetivo, append, 'Tonificar'),
    send(@objetivo, append, 'Resistencia Cardiovascular'),
    send(@objetivo, append, 'Mejorar la postura'),
    send(@mainDialog, append, button(recomendar, message(@prolog, obtener_recomendacion))),
    new(B1, button('Regresar', and(message(@prolog, principal)))),
    send(@mainDialog, append(B1)),
    send(@mainDialog, open).

obtener_recomendacion:-
    get(@input, selection, Usuario),
    get(@objetivo, selection, Objetivo),
    generar_recomendacion(Usuario, Objetivo, Recomendacion),
    mostrar_recomendacion('Recomendación de Entrenamiento', Recomendacion).

% Genera recomendaciones en base al objetivo de entrenamiento
%
generar_recomendacion(Usuario, 'Pérdida de Peso', Recomendacion):-
    atomic_list_concat(['Hola, ', Usuario, '. Para tu objetivo de pérdida de peso, te recomendamos hacer 45 minutos de cardio y 30 minutos de entrenamiento de fuerza tres veces por semana.'], Recomendacion).

generar_recomendacion(Usuario, 'Ganancia de Masa Muscular', Recomendacion):-
    atomic_list_concat(['Hola, ', Usuario, '. Para tu objetivo de ganancia de masa muscular, te recomendamos las siguientes acciones:',
    '\n',
    '1. Realizar entrenamientos de efectivos.\n',
    'Incorpora ejercicios compuestos (sentadillas, press de banca, peso muerto y pull-ups), para reclutar múltiples grupos musculares a la vez.\n',
    '2. Aplicar sobre carga progresiva en tus ejercicios.\n',
    'El principio de la sobrecarga progresiva implica aumentar gradualmente el peso que levantas para estimular el crecimiento muscular. Mantén registros de tus levantamientos para seguir progresando.\n',
    '3. Realizar suficientes series y repeticiones en tus ejercicios.\n',
    'Para ganar masa muscular, apunta a 6-8 repeticiones por serie. Esto generalmente es efectivo para hipertrofia muscular.\n',
    '4. Tener un descanso adecuado entre sesiones de entrenamiento.\n',
    'Da tiempo a tus músculos para recuperarse. Deja al menos 48 horas entre los entrenamientos de un grupo muscular específico.\n',
    '5. Consumir proteína de calidad en tu dieta.\n',
    '6. Opcionalmente, considerar consumir suplementos como proteína o creatina.'], Recomendacion).

generar_recomendacion(Usuario, 'Tonificar', Recomendacion):-
    atomic_list_concat(['Hola, ', Usuario, '. Para tu objetivo para tonificar, te recomendamos las siguientes acciones:',
    '\n',
    '1. Realizar entrenamientos de efectivos.\n',
    'Crea un programa de ejercicios que incluya ejercicios de resistencia (levantamiento de pesas) y cardio.\n',
    '2. Varia tus ejercicios.\n',
    'Cambiar tus ejercicios periódicamente evita el estancamiento y estimula el crecimiento muscular.\n',
    '3. Cardio.\n',
    'El cardio ayuda a reducir la grasa corporal y mejorar la definición muscular. Realiza ejercicios cardiovasculares, como correr, nadar o andar en bicicleta, varias veces a la semana.\n',
    '4. Tener un descanso adecuado entre sesiones de entrenamiento.\n',
    'Da tiempo a tus músculos para recuperarse. Deja al menos 48 horas entre los entrenamientos de un grupo muscular específico.\n',
    '5. Consumir proteína de calidad en tu dieta.\n',
    '6. Opcionalmente, considerar consumir suplementos como proteína o creatina.'], Recomendacion).


generar_recomendacion(Usuario, 'Resistencia Cardiovascular', Recomendacion):-
    atomic_list_concat(['Hola, ', Usuario, '. Para mejorar tu resistencia cardiovascular, te recomendamos las siguientes acciones:',
    '\n',
    '1. Entrenamientos de intervalos.\n',
    'Alterna períodos de alta intensidad con períodos de baja intensidad o de descanso. Por ejemplo, puedes correr a máxima velocidad durante 30 segundos y luego caminar o trotar durante 1-2 minutos.\n',
    '2. Varia tus ejercicios.\n',
    'Cambiar los ejercicios cardiovasculares que haces puede mantener el entrenamiento fresco y desafiante. Puedes alternar entre correr, nadar, andar en bicicleta, saltar la cuerda, remar y otras actividades cardiovasculares.\n',
    '3. Aumenta gradualmente la intensidad y la duración.\n',
    'El cardio ayuda a reducir la grasa corporal y mejorar la definición muscular. Realiza ejercicios cardiovasculares, como correr, nadar o andar en bicicleta, varias veces a la semana.\n',
    '4. Combinación de fuerza y cardio.\n',
    'Integra el entrenamiento de fuerza con ejercicios cardiovasculares en tu rutina. Esto puede incluir superconjuntos o circuitos que alternan entre ejercicios de resistencia y cardio.\n',
    '5. Opcionalmente, considerar consumir suplementos como proteína o creatina.'], Recomendacion).

generar_recomendacion(Usuario, 'Mejorar la postura', Recomendacion):-
    atomic_list_concat(['Hola, ', Usuario, '. Para mejorar tu postura, te recomendamos las siguientes acciones:',
    '\n',
    '1.Conciencia postural.\n',
    ' El primer paso para mejorar tu postura es ser consciente de ella. Fíjate en cómo te sientas, estás de pie o te mueves. Puedes pedir a un amigo o un entrenador que te observe y te dé retroalimentación sobre tu postura.\n',
    '2. Fortalece los músculos centrales.\n',
    'Los músculos del núcleo (abdominales, espalda baja y glúteos) son fundamentales para mantener una buena postura. Incluye ejercicios de fortalecimiento del core, como planchas y ejercicios de lumbares, en tu rutina de gimnasio.\n',
    '3. Ergonomía en el gimnasio.\n',
    'Asegúrate de que tus equipos y máquinas de entrenamiento estén configurados adecuadamente para tu cuerpo. Ajusta las alturas y posiciones de los asientos, manijas y respaldos según tus necesidades.\n',
    '4. Evita el sobreentrenamiento.\n',
    'Entrenar en exceso o de manera incorrecta puede causar fatiga muscular y llevar a una mala postura. Dale a tus músculos tiempo para recuperarse entre sesiones de entrenamiento.\n',
    '5. Mantén una postura ergonómica en la vida diaria.'], Recomendacion).


% Muestra la recomendación en una ventana emergente
mostrar_recomendacion(Titulo, Recomendacion):-
     send(@mainDialog, size, size(400, 200)),  % Ajusta el tamaño de la ventana
    new(@recomendacionDialog, dialog(Titulo)),
    send(@recomendacionDialog, append, text('Tu recomendación de entrenamiento es:')),
    send(@recomendacionDialog, append, text(Recomendacion)),
    send(@recomendacionDialog, append, button(cerrar, message(@recomendacionDialog, destroy))),
    send(@recomendacionDialog, open).

:-menu.
