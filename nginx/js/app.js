// Lógica del sitio de prueba: estado del servidor, IP del visitante,
// indicadores económicos y cuenta regresiva de cumpleaños.
'use strict';

// Fecha del cumpleaños (mes 1-12, día). La cuenta regresiva salta sola al año siguiente.
const BIRTHDAY = { month: 5, day: 26 };

const $ = (id) => document.getElementById(id);

// fetch con tiempo límite para que una API caída no deje la página "cargando" para siempre.
function fetchWithTimeout(url, options = {}, ms = 8000) {
	const controller = new AbortController();
	const timer = setTimeout(() => controller.abort(), ms);
	return fetch(url, { ...options, signal: controller.signal }).finally(() => clearTimeout(timer));
}

async function fetchJson(url) {
	const response = await fetchWithTimeout(url);
	if (!response.ok) throw new Error(`HTTP ${response.status}`);
	return response.json();
}

// Crea una lista <dl> de pares etiqueta/valor sin usar innerHTML (evita inyectar HTML desde las APIs).
function buildKvList(rows, extraClass = '') {
	const list = document.createElement('dl');
	list.className = 'kv-list';
	for (const [label, value] of rows) {
		if (value === undefined || value === null || value === '') continue;
		const row = document.createElement('div');
		row.className = `kv ${extraClass}`.trim();
		const dt = document.createElement('dt');
		dt.textContent = label;
		const dd = document.createElement('dd');
		dd.textContent = value;
		row.append(dt, dd);
		list.append(row);
	}
	return list;
}

function showError(container, message) {
	const p = document.createElement('p');
	p.className = 'error';
	p.textContent = message;
	container.replaceChildren(p);
	container.setAttribute('aria-busy', 'false');
}

/* ---------- Estado del servidor ---------- */
async function checkServer() {
	const status = $('server-status');
	const text = $('status-text');

	$('srv-host').textContent = location.host || 'archivo local';
	$('srv-protocol').textContent = location.protocol.replace(':', '').toUpperCase();

	if (location.protocol === 'file:') {
		status.classList.add('is-err');
		text.textContent = 'Abierto como archivo local (sin servidor)';
		return;
	}

	try {
		const start = performance.now();
		const response = await fetchWithTimeout(location.pathname, { method: 'HEAD', cache: 'no-store' }, 5000);
		const latency = Math.round(performance.now() - start);
		$('srv-latency').textContent = `${latency} ms`;
		$('srv-software').textContent = response.headers.get('server') || 'oculto';
		status.classList.add(response.ok ? 'is-ok' : 'is-err');
		text.textContent = response.ok ? 'Servidor en línea' : `El servidor respondió ${response.status}`;
	} catch {
		status.classList.add('is-err');
		text.textContent = 'No se pudo contactar al servidor';
	}
}

function startClock() {
	const formatter = new Intl.DateTimeFormat('es-CL', { dateStyle: 'medium', timeStyle: 'medium' });
	const tick = () => { $('srv-clock').textContent = formatter.format(new Date()); };
	tick();
	setInterval(tick, 1000);
}

/* ---------- Información de IP ---------- */
// Cada proveedor se normaliza al mismo formato. ip-api.com solo funciona por HTTP en su plan
// gratuito, así que si el sitio se sirve por HTTPS se usa ipwho.is.
const ipProviders = {
	'ip-api.com': async () => {
		const fields = 'status,message,continent,country,countryCode,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,mobile,proxy,hosting,query';
		const d = await fetchJson(`http://ip-api.com/json/?fields=${fields}&lang=es`);
		if (d.status !== 'success') throw new Error(d.message || 'respuesta inválida');
		return {
			ip: d.query, continent: d.continent, country: d.country, countryCode: d.countryCode,
			region: d.regionName, city: d.city, district: d.district, postal: d.zip,
			lat: d.lat, lon: d.lon, timezone: d.timezone, utcOffset: d.offset,
			currency: d.currency, isp: d.isp, org: d.org, asn: d.as,
			ipType: d.query && d.query.includes(':') ? 'IPv6' : 'IPv4',
			flags: { 'Móvil': d.mobile, 'Proxy / VPN': d.proxy, 'Hosting': d.hosting },
		};
	},
	'ipwho.is': async () => {
		const d = await fetchJson('https://ipwho.is/?lang=es');
		if (d.success === false) throw new Error(d.message || 'respuesta inválida');
		const c = d.connection || {};
		const tz = d.timezone || {};
		return {
			ip: d.ip, continent: d.continent, country: d.country, countryCode: d.country_code,
			region: d.region, city: d.city, postal: d.postal,
			lat: d.latitude, lon: d.longitude, timezone: tz.id, utcOffset: tz.offset,
			isp: c.isp, org: c.org, asn: c.asn ? `AS${c.asn}` : undefined, asName: c.domain,
			flag: d.flag && d.flag.emoji,
			ipType: d.type,
		};
	},
};

function formatUtcOffset(seconds) {
	if (!Number.isFinite(seconds)) return undefined;
	const sign = seconds < 0 ? '−' : '+';
	const abs = Math.abs(seconds);
	const h = String(Math.floor(abs / 3600)).padStart(2, '0');
	const m = String(Math.floor((abs % 3600) / 60)).padStart(2, '0');
	return `UTC${sign}${h}:${m}`;
}

function renderIp(info, provider) {
	const container = $('ip-info');

	const main = document.createElement('div');
	main.className = 'ip-main';
	const ip = document.createElement('span');
	ip.className = 'ip-address';
	ip.textContent = info.ip;
	const place = document.createElement('span');
	place.className = 'ip-place';
	place.textContent = [info.flag, [info.city, info.region, info.country].filter(Boolean).join(', ')]
		.filter(Boolean).join(' ');
	main.append(ip, place);

	const flags = document.createElement('div');
	flags.className = 'ip-flags';
	const addChip = (label, highlight = false) => {
		const chip = document.createElement('span');
		chip.className = highlight ? 'chip on' : 'chip';
		chip.textContent = label;
		flags.append(chip);
	};
	if (info.ipType) addChip(info.ipType);
	for (const [name, active] of Object.entries(info.flags || {})) {
		addChip(`${name}: ${active ? 'Sí' : 'No'}`, active);
	}

	const hasCoords = Number.isFinite(info.lat) && Number.isFinite(info.lon);
	const details = buildKvList([
		['Proveedor (ISP)', info.isp],
		['Organización', info.org],
		['Sistema autónomo', [info.asn, info.asName].filter(Boolean).join(' · ')],
		['Continente', info.continent],
		['País', info.countryCode ? `${info.country} (${info.countryCode})` : info.country],
		['Región', info.region],
		['Ciudad', info.city],
		['Distrito', info.district],
		['Código postal', info.postal],
		['Coordenadas', hasCoords ? `${info.lat.toFixed(4)}, ${info.lon.toFixed(4)}` : undefined],
		['Zona horaria', [info.timezone, formatUtcOffset(info.utcOffset)].filter(Boolean).join(' · ')],
		['Moneda', info.currency],
	]);

	container.replaceChildren(main, flags, details);
	container.setAttribute('aria-busy', 'false');
	$('ip-source').textContent = `vía ${provider}`;
}

async function loadIpInfo() {
	const order = location.protocol === 'https:' ? ['ipwho.is'] : ['ip-api.com', 'ipwho.is'];
	for (const name of order) {
		try {
			renderIp(await ipProviders[name](), name);
			return;
		} catch (error) {
			console.warn(`No se pudo obtener la IP desde ${name}:`, error);
		}
	}
	showError($('ip-info'), 'No se pudo obtener la información de tu IP.');
}

/* ---------- Indicadores económicos ---------- */
const ECONOMIC_INDICATORS = [
	['uf', 'UF'],
	['dolar', 'Dólar observado'],
	['dolar_intercambio', 'Dólar acuerdo'],
	['euro', 'Euro'],
	['utm', 'UTM'],
	['ivp', 'IVP'],
	['ipc', 'IPC'],
	['imacec', 'Imacec'],
];

const clp = new Intl.NumberFormat('es-CL', { style: 'currency', currency: 'CLP', minimumFractionDigits: 2, maximumFractionDigits: 2 });
const num = new Intl.NumberFormat('es-CL', { maximumFractionDigits: 2 });

function formatIndicator(indicator) {
	if (!indicator || !Number.isFinite(indicator.valor)) return 'No disponible';
	const unit = (indicator.unidad_medida || '').toLowerCase();
	if (unit === 'pesos') return clp.format(indicator.valor);
	if (unit === 'porcentaje') return `${num.format(indicator.valor)} %`;
	return `${num.format(indicator.valor)} ${indicator.unidad_medida || ''}`.trim();
}

async function loadEconomicIndicators() {
	const container = $('economic-indicators');
	try {
		const data = await fetchJson('https://mindicador.cl/api');
		const rows = ECONOMIC_INDICATORS.map(([key, name]) => [name, formatIndicator(data[key])]);
		container.replaceChildren(buildKvList(rows, 'eco'));
		container.setAttribute('aria-busy', 'false');

		const date = data.uf && data.uf.fecha ? new Date(data.uf.fecha) : null;
		if (date && !Number.isNaN(date.getTime())) {
			$('eco-date').textContent = date.toLocaleDateString('es-CL', { day: 'numeric', month: 'short', year: 'numeric' });
		}
	} catch (error) {
		console.error('Error al consultar los indicadores económicos:', error);
		showError(container, 'No se pudieron cargar los indicadores económicos.');
	}
}

/* ---------- Cuenta regresiva ---------- */
function startCountdown() {
	const DAY = 24 * 60 * 60 * 1000;
	const parts = { days: $('days'), hours: $('hours'), minutes: $('minutes'), seconds: $('seconds') };
	const countdown = $('countdown');
	const items = [...countdown.children];
	let celebrating = false;

	// Devuelve el próximo cumpleaños; si hoy es el día, devuelve el de hoy.
	function nextBirthday(now) {
		let target = new Date(now.getFullYear(), BIRTHDAY.month - 1, BIRTHDAY.day);
		if (now - target >= DAY) target = new Date(now.getFullYear() + 1, BIRTHDAY.month - 1, BIRTHDAY.day);
		return target;
	}

	function tick() {
		const now = new Date();
		const target = nextBirthday(now);
		const diff = target - now;
		$('cd-date').textContent = target.toLocaleDateString('es-CL', { day: 'numeric', month: 'long', year: 'numeric' });

		if (diff <= 0) {
			if (!celebrating) {
				const msg = document.createElement('p');
				msg.className = 'countdown-done';
				msg.textContent = '🎉 ¡Hoy es mi cumpleaños! 🎂';
				countdown.replaceChildren(msg);
				celebrating = true;
			}
			return;
		}
		if (celebrating) {
			countdown.replaceChildren(...items);
			celebrating = false;
		}

		parts.days.textContent = String(Math.floor(diff / DAY)).padStart(2, '0');
		parts.hours.textContent = String(Math.floor((diff % DAY) / 3600000)).padStart(2, '0');
		parts.minutes.textContent = String(Math.floor((diff % 3600000) / 60000)).padStart(2, '0');
		parts.seconds.textContent = String(Math.floor((diff % 60000) / 1000)).padStart(2, '0');
	}

	tick();
	setInterval(tick, 1000);
}

/* ---------- Fondo de partículas ---------- */
// Usa particles.js (js/vendor/particles.min.js). Si el archivo no cargó, la página sigue igual.
function startParticles() {
	if (typeof window.particlesJS !== 'function') return;
	const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
	const isSmall = window.innerWidth < 700;

	window.particlesJS('particles-js', {
		particles: {
			number: { value: isSmall ? 35 : 80, density: { enable: true, value_area: 900 } },
			// Mismos colores del logotipo "Holograma".
			color: { value: ['#4285f4', '#ea4335', '#fbbc05', '#34a853', '#a855f7'] },
			shape: { type: 'circle' },
			opacity: { value: 0.6, random: true },
			size: { value: 3, random: true },
			line_linked: { enable: true, distance: 140, color: '#60a5fa', opacity: 0.25, width: 1 },
			move: { enable: !reduceMotion, speed: 1.6, direction: 'none', random: false, straight: false, out_mode: 'out' },
		},
		interactivity: {
			// 'window' porque el lienzo está detrás de las tarjetas y no recibe el mouse directamente.
			detect_on: 'window',
			events: {
				onhover: { enable: !isSmall, mode: 'grab' },
				onclick: { enable: true, mode: 'push' },
				resize: true,
			},
			modes: {
				grab: { distance: 160, line_linked: { opacity: 0.6 } },
				push: { particles_nb: 3 },
			},
		},
		retina_detect: true,
	});
}

/* ---------- Inicio ---------- */
startParticles();
$('year').textContent = new Date().getFullYear();
startClock();
startCountdown();
checkServer();
loadIpInfo();
loadEconomicIndicators();
