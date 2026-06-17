workspace "App de Transporte - C4" "Modelo C4 basado en el documento App de Transporte" {
	
	model {
		lider = person "Líder de Transporte" "Consulta y monitorea la operación en tiempo real."
		coordinador = person "Coordinador de Transporte" "Monitorea la operación y gestiona disponibilidad de recursos."
		supervisor = person "Supervisor de Transporte" "Valida documentación y monitorea la ejecución."
		analista = person "Analista de Transporte" "Opera el manager: asigna unidades, tripulación, documentos e incidencias."
		planeador = person "Planeador Logístico" "Configura pedidos en SAP, asigna cortina y valida coordenadas, puede actualizar coordenadas  de pdv desde la plataforma."
		auxiliar = person "Auxiliar de Patio" "Ejecuta movimiento a cortina y envío a resguardo."
		// chofer = person "Chofer" "Consulta ruta/documentos y reporta incidencias desde la app móvil/actualiza coordenadas."
		chofer = person "Chofer" "Consulta ruta/actualiza coordenadas."
		
		gerente = person "Gerente de Logística" "Consulta el dashboard y seguimiento operativo.","actualiza"
		trafico = person "Área de Tráfico" "Recibe notificaciones internas y da seguimiento a salidas/incidencias."
		taller = person "Área de Taller" "Valida condición operativa de unidades con falla."
		//cavi = person "//cavi" "Recibe alertas de incidencias en ruta."
		fletera = person "Proveedor Fletero" "Recibe notificaciones de salida y asigna chofer para unidades fleteras."
		
		//Systemas relacionados
		sap = softwareSystem "SAP" "Sistema maestro para pedidos, catálogos, estatus operativos, documentos y eventos de salida/carga."
		managerCredito_cobranza = softwareSystem "Manager de Crédito y Cobranza" "Plataforma del área de Crédito y Cobranza para revisar, autorizar o rechazar solicitudes y actualizar coordenadas aprobadas en SAP." {
			ccweb = container "Portal Web Crédito y Cobranza" "Interfaz para revisar solicitudes y aprobar o rechazar cambios." "Web App"
			ccapi = container "API Manager Crédito y Cobranza" "Recibe solicitudes de coordenadas, gestiona validación y envía actualizaciones aprobadas a SAP." "API" {
				recepcion = component "Módulo de Recepción de Solicitudes" "Recibe la solicitud enviada desde Transporte y valida estructura, campos obligatorios y contexto mínimo." "Business Module"
				validacion = component "Módulo de Gestión de Solicitudes de Coordenadas" "Gestiona la aprobación o rechazo de actualizaciones de coordenadas que requieren validación." "Business Module"
				pendientesSap = component "Módulo de Pendientes de Envío a SAP / Outbox" "Guarda coordenadas aprobadas pendientes de enviar a SAP, controla reintentos, errores e idempotencia para evitar pérdida o duplicidad de actualizaciones." "Worker Module"
				integracionSap = component "Módulo de Integración SAP" "Envía a SAP las coordenadas aprobadas y procesa la respuesta de confirmación." "Worker Module"
				trazabilidad = component "Módulo de Trazabilidad" "Registra estatus, comentarios, usuario, fecha, coordenadas actuales, coordenadas nuevas y resultado de integración." "Business Module"
			}
			
			ccdb = container "Base de Datos Manager Crédito y Cobranza" "Almacena solicitudes, coordenadas actuales, coordenadas propuestas, estatus, comentarios y trazabilidad." "Database" "Database"
		}
		
		siccos = softwareSystem "SICCOS" "Sistema fuente para consultar datos del chofer, como nombre, número de nómina y RFC."
		// sasip = softwareSystem "SASIP" "Sistema de asistencia para precarga de choferes y ayudantes."
		whatsapp = softwareSystem "WhatsApp / Proveedor de mensajería" "Canal de notificación de rutas y salidas."
		gps = softwareSystem "Servicio GPS / Geolocalización" "Fuente de ubicación de unidades y coordenadas móviles."
		transporte = softwareSystem "Plataforma de Transporte" "Sistema central para asignación, ejecución y monitoreo operativo del transporte." {
			webapp = container "Aplicación Web / Manager" "Interfaz web para operación de transporte y administración, actualización de coordenados PDV." "Web App"
			mobile = container "Aplicación Móvil de Chofer" "Consulta de ruta, documentos, mensajes e incidencias." "Mobile App"
			api = container "API / Backend de Transporte" "Expone servicios de negocio, seguridad, reglas y trazabilidad." "Backend/API" "API" {
				//rutas = component "Módulo de Rutas" "Consulta desde SAP los transportes activos, ruta asignada, clientes e interlocutores asociados al chofer." "Business Module"
				asignaciones = component "Módulo de Asignaciones" "Gestiona pedidos, asignación de unidad y tripulación, y registro de chofer fletero." "Business Module"
				patio = component "Módulo de Operación en Patio" "Controla notificación a patio, movimiento a cortina y envío a resguardo." "Business Module"
				documental = component "Módulo de Documentación" "Carga, validación y consulta de documentos de transporte." "Business Module"
				mensajeria = component "Módulo de Mensajería y Notificaciones" "Envía mensajes operativos y notificaciones de salida." "Business Module"
				incidencias = component "Módulo de Incidencias" "Registra fallas, clasificación operativa y continuidad/transbordo." "Business Module"
				catalogos = component "Módulo de Catálogos y Accesos" "Gestiona choferes, ayudantes, vehículos, accesos fleteros y estatus." "Business Module"
				//coordenadas = component "Módulo de Coordenadas" "Recibe propuestas de actualización GPS y las valida/envía a SAP." "Business Module"
				historico = component "Módulo de Historial Operativo" "Registra eventos, mensajes y trazabilidad del pedido." "Business Module"
				monitoreo = component "Módulo de Dashboard / Monitoreo" "Consolida operación, mapa, filtros, estatus y alertas." "Business Module"
				coordenadas = component "Módulo de Coordenadas" "Gestiona actualización de coordenadas.  Canaliza solicitudes del chofer hacia la API del Manager." "Business Module"
				autenticacionChofer = component "Módulo de Autenticación de Chofer" "Valida el acceso del chofer consultando servicion SICCOS mediante nómina y RFC, y relaciona el usuario con su transporte activo." "Business Module"
				rutasChofer = component "Módulo de Rutas y Transportes del Chofer" "Consulta desde la base operativa los transportes activos, ruta asignada, clientes e interlocutores previamente sincronizados desde SAP"
				sincronizacionLocal = component "Módulo de Sincronización Local" "Administra datos locales/cacheados de rutas, transportes, clientes, interlocutores y coordenadas actuales para consulta de la app aun cuando SAP no esté disponible." "Business Module"
				outbox = component "Módulo de Cola Local / Outbox" "Registra eventos pendientes de enviar a sistemas externos, controla estatus, reintentos, errores e idempotencia." "Business Module"
				integracionAsincrona = component "Módulo de Integración Asíncrona" "Procesa eventos pendientes desde la cola local y ejecuta integraciones con SAP y Manager de Crédito y Cobranza sin depender de peticiones en tiempo real." "Worker Module"
				recepcionAsignacionSap = component "Módulo de Recepción de Asignación SAP" "Recibe desde SAP la asignación del chofer al transporte, incluyendo número de transporte, ruta, clientes, interlocutores y coordenadas actuales; valida estructura y actualiza la base operativa local." "Business Module"
			}
			jobs = container "Motor de Integraciones y Notificaciones" "Sincroniza datos con SAP, envía WhatsApp y procesa eventos asíncronos." "Worker/Jobs"
			db = container "Base de Datos Operativa" "Persistencia de pedidos, asignaciones, incidencias, documentos, mensajes, coordenadas y trazabilidad." "Database" "Database" {
				nombre = component "nombre" "nombre de la persona" "Business Module"
			}
			docs = container "Repositorio de Documentos" "Almacena archivos cargados y documentos validados del transporte." "File Storage"
			dashboard = container "Dashboard de Monitoreo" "Vista consolidada de solo consulta para operación en tiempo real." "Web Module"
		}
		
		//conexiones nive 1
		//transporte -> managerCredito_cobranza  "Envía solicitud de actualización de coordenadas"
		
		//conexion nivel 2
		lider -> dashboard "Consulta operación"
		coordinador -> dashboard "Monitorea operación"
		coordinador -> catalogos "Valida disponibilidad de recursos"
		gerente -> dashboard "Consulta indicadores y seguimiento"
		
		supervisor -> webapp "Valida documentación y monitorea"
		supervisor -> documental "Aprueba o rechaza documentos"
		
		analista -> webapp "Gestiona asignaciones, documentos e incidencias"
		analista -> asignaciones "Asigna unidad y tripulación"
		analista -> documental "Carga documentación"
		analista -> mensajeria "Envía mensajes al chofer"
		analista -> incidencias "Gestiona fallas y transbordos"
		
		planeador -> webapp "Consulta pedidos, asigna cortina y valida/actualiza coordenadas"
		//planeador -> coordenadas "Aprueba o rechaza cambios GPS"
		
		auxiliar -> webapp "Ejecuta movimientos de patio"
		auxiliar -> patio "Opera movimientos en patio"
		
		//chofer -> mobile "Consulta ruta,reporta incidencias y actualiza coordenadas"
		chofer -> mobile "Inicia sesión, consulta ruta y actualiza coordenadas"
		//chofer -> documental "Consulta/descarga documentos"
		// chofer -> mensajeria "Recibe mensajes"
		//chofer -> mobile "Actualiza coordenadas del cliente"
		//mobile -> ccapi "Envía solicitud de actualización de coordenadas"
		autenticacionChofer -> siccos "Consulta y replica datos de chofer para persistencia local"
		autenticacionChofer -> db "Registra sesión, datos básicos del chofer y trazabilidad de acceso"
		autenticacionChofer -> outbox "Genera evento de sincronización de datos del chofer si requiere actualización local"
		autenticacionChofer -> rutasChofer "Solicita transporte activo del chofer autenticado"
		
		coordenadas -> rutasChofer "Valida que el cliente/interlocutor pertenezca a la ruta activa"
		coordenadas -> db "Guarda solicitud con estatus Pendiente de validación"
		coordenadas -> outbox "Publica evento CoordenadaPendienteValidacion"
		
		trafico -> dashboard "Da seguimiento operativo"
		
		
		
		fletera -> whatsapp "Recibe aviso de ruta/salida"
		//cavi -> dashboard "Consulta alertas de incidencias"
		taller -> webapp "Valida condición de unidad"
		
		webapp -> api "Usa/solicita actualización de coordenadas de PDV"
		webapp -> asignaciones "Contiene / usa"
		webapp -> patio "Contiene / usa"
		webapp -> documental "Contiene / usa"
		webapp -> mensajeria "Contiene / usa"
		webapp -> incidencias "Contiene / usa"
		webapp -> catalogos "Contiene / usa"
		//webapp -> ccapi "Contiene / usa"
		webapp -> historico "Consulta"
		
		//mobile -> api "Usa, Actualiza coordenadas del cliente"
		mobile -> api "Envía credenciales, consulta ruta y registra coordenadas GPS"
		
		mobile -> autenticacionChofer "Envía nómina y RFC para iniciar sesión"
		//rutasChofer -> mobile "Sincroniza información de rutas, clientes y documentos operativos"
		// mobile -> rutasChofer "Consulta transporte activo, ruta, clientes e interlocutores"
		mobile -> coordenadas "Envía coordenadas GPS propuestas"
		mobile -> rutasChofer "Consulta transporte activo, ruta, clientes e interlocutores"
		// rutasChofer -> sap "Consulta transporte, ruta, clientes, interlocutores y coordenadas actuales"
		// rutasChofer -> db "Registra consulta de ruta y trazabilidad"
		// rutasChofer -> coordenadas "Proporciona contexto de cliente/interlocutor para actualización de coordenadas"
		rutasChofer -> db "Consulta ruta, transporte, clientes e interlocutores sincronizados desde SAP"
		sap -> integracionAsincrona  "Sincroniza información de rutas, clientes"
		//rutasChofer -> sap "Consulta transporte activo, ruta, clientes, interlocutores y coordenadas actuales"
		rutasChofer -> db "Guarda/cachea transporte, ruta y trazabilidad de consulta"
		//rutasChofer -> db "Consulta transporte, ruta, clientes e interlocutores recibidos desde SAP"
		rutasChofer -> mobile "Devuelve ruta asignada y puntos de entrega"
		//mobile -> api "Envía actualización de coordenadas"
		
		ccweb -> ccapi "Consulta y valida solicitudes"
		ccweb -> ccapi "Captura manualmente o valida solicitudes de actualización de coordenadas"
		//ccweb -> capturaManual "Registra solicitud manual de actualización"
		ccapi -> ccdb "Guarda y consulta solicitudes"
		ccapi -> sap "Envía coordenadas aprobadas"
		//ccapi -> sap "Envía actualización aprobada (ZSD_COORDENADAS)"
		// ccapi -> sap "Envía actualización aprobada mediante ZSD_COORDENADAS"
		
		sap -> ccapi "Confirma actualización"
		
		dashboard -> api "Consulta"
		
		//api -> ccapi "Envía solicitud de actualización de coordenadas para validación"
		//api -> recepcion "Envía solicitud de actualización de coordenadas para validación"
		api -> mobile "Devuelve sesión válida, transporte activo, ruta, clientes e interlocutores"
		api -> db "Lee y escribe"
		api -> docs "Guarda y consulta documentos"
		api -> jobs "Solicita integraciones y notificaciones"
		
		// api -> sap " consulta  informacion del transporte"
		//api -> siccos "Consulta datos del chofer para autenticación"
		//jobs -> sap "Consume y envía información"
		//jobs -> sasip "Sincroniza choferes/ayudantes"
		jobs -> whatsapp "Envía notificaciones"
		jobs -> gps "Recibe ubicación / consulta coordenadas"
		jobs -> db "Actualiza eventos y estados"
		jobs -> docs "Recupera documentos para distribución"
		
		//coordenadas -> ccapi "Envía solicitud de actualización de coordenadas para validación"
		dashboard -> monitoreo "Presenta"
		
		//asignaciones -> sap "Obtiene pedidos, unidades y restricciones"
		// patio -> sap "Recibe eventos de carga/fin de carga"
		documental -> docs "Almacena archivos"
		documental -> historico "Registra eventos documentales"
		mensajeria -> whatsapp "Notifica salida/ruta"
		mensajeria -> historico "Registra envío/lectura"
		incidencias -> historico "Registra fallas y decisiones"
		incidencias -> monitoreo "Publica alertas"
		//catalogos -> sap "Obtiene catálogo de unidades"
		//atalogos -> sasip "Obtiene choferes y ayudantes"
		mobile -> gps "Obtiene ubicación actual del dispositivo"
		
		// historico -> db "Persiste eventos"
		monitoreo -> db "Consulta operación consolidada"
		monitoreo -> gps "Consulta ubicación en tiempo real"
		//monitoreo -> sap "Consulta eventos operativos relevantes"
		asignaciones -> catalogos "Consulta catálogos y disponibilidad"
		asignaciones -> historico "Registra asignaciones y cambios"
		patio -> historico "Registra movimientos en patio"
		documental -> historico "Registra validaciones y cambios"
		documental -> docs "Almacena y recupera archivos"
		mensajeria -> historico "Registra envío, entrega y lectura"
		incidencias -> historico "Registra fallas, clasificación y decisiones"
		incidencias -> monitoreo "Publica alertas e incidencias activas"
		// coordenadas -> historico "Registra propuestas y validaciones"
		monitoreo -> historico "Consulta trazabilidad del pedido"
		
		recepcion -> trazabilidad "Registra solicitud recibida"
		recepcion -> validacion "Canaliza solicitud para revisión"
		//capturaManual -> trazabilidad "Registra solicitud manual"
		// capturaManual -> validacion "Canaliza solicitud manual para revisión"
		
		validacion -> trazabilidad "Actualiza estatus y comentarios"
		// validacion -> integracionSap "Solicita envío de coordenadas aprobadas"
		validacion -> pendientesSap "Publica coordenada aprobada para envío a SAP"
		pendientesSap -> integracionSap "Entrega coordenadas aprobadas pendientes de envío"
		pendientesSap -> ccdb "Persiste eventos pendientes, intentos, errores y estatus de integración"
		integracionSap -> pendientesSap "Actualiza estatus de envío, error o reintento"
		
		outbox -> db "Persiste eventos pendientes, estatus, número de intentos y errores"
		
		integracionAsincrona -> outbox "Lee eventos pendientes"
		integracionAsincrona -> ccapi "Envía solicitud de coordenadas al Manager de Crédito y Cobranza"
		//integracionAsincrona -> sap "Sincroniza datos maestros/rutas desde SAP cuando exista conectividad"
		integracionAsincrona -> db "Actualiza estatus local según resultado de integración"
		integracionAsincrona -> historico "Registra envío, error o reintento"
		
		
		//sincronizacionLocal -> sap "Consulta transportes, rutas, clientes, interlocutores y coordenadas actuales"
		sincronizacionLocal -> db "Actualiza copia local sincronizada"
		sincronizacionLocal -> outbox "Lee eventos pendientes para reprocesamiento"
		historico -> db "Persiste trazabilidad operativa"
		
		integracionSap -> sap "Envía actualización aprobada"
		integracionSap -> ccdb "Actualiza resultado de integración"
		trazabilidad -> ccdb "Guarda y consulta trazabilidad"
		validacion -> ccdb "Consulta solicitud y estatus"
		recepcion -> ccdb "Guarda solicitud inicial"
		
		
		sap -> integracionSap "Confirma resultado de actualización"
		sap -> recepcionAsignacionSap "Envía asignación de chofer, transporte, ruta, clientes e interlocutores"
		//capturaManual -> ccdb "Guarda solicitud manual"
		
		recepcionAsignacionSap -> db "Guarda transporte asignado, ruta, clientes, interlocutores y coordenadas actuales"
		recepcionAsignacionSap -> historico "Registra evento de asignación recibida desde SAP"
		recepcionAsignacionSap -> sincronizacionLocal "Entrega datos recibidos para normalización y actualización local"
		api -> recepcion "Envía solicitud de actualización de coordenadas para validación"
		
		
	}
	
	views {
		systemContext transporte "contexto-choferes" {
			
			include chofer
			// include planeador
			include managerCredito_cobranza
			include Transporte
			include SAP
			include siccos
			title "C4 - nivel 1 contexo | chofer"
			autolayout lr
		}
		container transporte "sprint-mvp-chofer-ruta-coordenadas" {
			include chofer
			// include planeador
			include mobile
			include api
			include db
			include siccos
			include managerCredito_cobranza
			include sap
			//include gps
			
			autolayout lr
			title "C4 - Sprint MVP Chofer | Login, Ruta y Actualización de Coordenadas"
		}
		container managerCredito_cobranza "sprint-mvp-manager" {
			
			include ccweb
			include ccapi
			include ccdb
			include sap
			//include gps
			include transporte
			
			autolayout lr
			title "C4 - Sprint MVP manager | actualizacion de coordenadas"
		}
		component api "componentes-api-mvp" {
			include chofer
			include mobile
			include autenticacionChofer
			include rutasChofer
			include coordenadas
			include sincronizacionLocal
			include outbox
			include integracionAsincrona
			include historico
			include db
			include ccapi
			include sap
			include siccos
			
			autolayout lr
			title "C4 - Nivel 3 Componentes | Backend Transporte MVP Asíncrono"
		}
		component ccapi "componentes-apiCredito-Cobranza-mvp" {
			include recepcion
			
			//include capturaManual
			include validacion
			include trazabilidad
			include sap
			include integracionSap
			include pendientesSap
			include transporte
			autolayout lr
			title "C4 - Nivel 3 Componentes Sprint MVP chofer  | Backend / API de Credito-Cobranza "
		}
		
		
		// container transporte "contenedores" {
			//     include *
			//     exclude lider
			//     exclude coordinador
			//     exclude supervisor
			//     exclude analista
			//     exclude planeador
			//     exclude auxiliar
			//     exclude chofer
			//     exclude gerente
			//     exclude trafico
			//     exclude taller
			//     //exclude //cavi
			//     exclude fletera
			//     autolayout lr
			//     title "C4 - Nivel 2 Contenedores | Plataforma de Transporte"
			// }
			// container transporte "contenedores-mvp_chofer"{
				//     //include chofer
				//     include managerCredito_cobranza
				//     include SAP
				//     include API
				//     include mobile
				//     include SAP
				//     include ccapi
				//     include chofer
				//     //include planeador
				//     include webapp
				//     autoLayout lr
				
				//     title "C4 - Nivel 2 Contenedores | chofer"
				
				// }
				
				
				
				
				
				
				
				// component api "componentes-api" {
					//     include asignaciones
					//     include patio
					//     include documental
					//     include mensajeria
					//     include incidencias
					//     include catalogos
					//     // include coordenadas
					//     include historico
					//     include monitoreo
					//     include sap
					//     //include sasip
					//     include whatsapp
					//     include gps
					//     include db
					//     include docs
					//     include webapp
					//     include mobile
					//     include dashboard
					//     include analista
					//     include supervisor
					//     include planeador
					//     include coordinador
					//     include auxiliar
					//     include chofer
					//     include trafico
					//     include taller
					//     //include //cavi
					//     autolayout lr
					//     title "C4 - Nivel 3 Componentes | Backend / API de Transporte"
					// }
					
					
					// component api "modulo-asignaciones" "Detalle del módulo de asignaciones" {
						//     include asignaciones
						//     include catalogos
						//     include historico
						//     include webapp
						//     //include *
						//     autolayout lr
						// }
						
						// component ccapi "c3-actualizacion-coordenadas" {
							//     include recepcion
							//     include validacion
							//     include capturaManual
							//     include trazabilidad
							//     include integracionSap
							//     include api
							//     include ccweb
							//     include ccdb
							//     include sap
							//     autolayout lr
							
							//     title "C4 - Nivel 3 Componentes | Actualización de coordenadas"
							// }
							
							
							// systemContext transporte "contexto-General" {
								//     include *
								//     exclude gerente
								//     // include chofer
								//     autolayout lr
								//     title "C4 - Nivel 1 Contexto | Plataforma de Transporte"
								// }
								
								
								
								
								
								styles {
									element "Person" {
										background #08427b
										color #ffffff
										shape person
									}
									element "Software System" {
										background #1168bd
										color #ffffff
									}
									element "Container" {
										background #438dd5
										color #ffffff
									}
									element "Component" {
										background #85bbf0
										color #000000
									}
									element "Database" {
										shape Cylinder
									}
									element "API"{
										background #2D7FF9
										color #ffffff
										shape RoundedBox
										
									}
								}
								
								
								
							}
							
							
						}
						