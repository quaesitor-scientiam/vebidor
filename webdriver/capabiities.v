module webdriver

import x.json2 as json

pub struct Timeouts {
	pub mut:
	implicit   ?int
	page_load  ?int @[json: 'pageLoad']
	script     ?int
}

pub struct Proxy {
	pub mut:
	proxy_type string   @[json: 'proxyType']
	http_proxy ?string  @[json: 'httpProxy']
	ssl_proxy  ?string  @[json: 'sslProxy']
	no_proxy   ?[]string @[json: 'noProxy']
}

pub struct EdgeOptions {
	pub mut:
	args       ?[]string
	extensions ?[]string
	binary     ?string
}

pub struct Capabilities {
pub mut:
	browser_name              ?string     @[json: 'browserName']
	browser_version           ?string     @[json: 'browserVersion']
	platform_name             ?string     @[json: 'platformName']
	accept_insecure_certs     ?bool       @[json: 'acceptInsecureCerts']
	page_load_strategy        ?string     @[json: 'pageLoadStrategy']
	unhandled_prompt_behavior ?string     @[json: 'unhandledPromptBehavior']
	timeouts                  ?Timeouts   @[json: 'timeouts']
	proxy                     ?Proxy      @[json: 'proxy']
	edge_options              ?EdgeOptions @[json: 'ms:edgeOptions']
}

pub struct NewSessionCaps {
pub:
	always_match map[string]json.Any   @[json: 'alwaysMatch']
	first_match  ?[]map[string]json.Any @[json: 'firstMatch']
}

pub struct NewSessionParams {
pub:
	capabilities NewSessionCaps @[json: 'capabilities']
}

pub fn (caps Capabilities) to_session_params() NewSessionParams {
	mut m := map[string]json.Any{}

	if name := caps.browser_name {
		m['browserName'] = json.Any(name)
	}
	if ver := caps.browser_version {
		m['browserVersion'] = json.Any(ver)
	}
	if plat := caps.platform_name {
		m['platformName'] = json.Any(plat)
	}
	if aic := caps.accept_insecure_certs {
		m['acceptInsecureCerts'] = json.Any(aic)
	}
	if pls := caps.page_load_strategy {
		m['pageLoadStrategy'] = json.Any(pls)
	}
	if upb := caps.unhandled_prompt_behavior {
		m['unhandledPromptBehavior'] = json.Any(upb)
	}
	if t := caps.timeouts {
		m['timeouts'] = json.Any(json.map_from(t))
	}
	if p := caps.proxy {
		mut proxy_map := map[string]json.Any{}
		proxy_map['proxyType'] = json.Any(p.proxy_type)
		if http := p.http_proxy {
			proxy_map['httpProxy'] = json.Any(http)
		}
		if ssl := p.ssl_proxy {
			proxy_map['sslProxy'] = json.Any(ssl)
		}
		if no_proxy := p.no_proxy {
			mut entries := []json.Any{}
			for item in no_proxy {
				entries << json.Any(item)
			}
			proxy_map['noProxy'] = json.Any(entries)
		}
		m['proxy'] = json.Any(proxy_map)
	}
	if eo := caps.edge_options {
		mut edge_map := map[string]json.Any{}
		if args := eo.args {
			mut arg_vals := []json.Any{}
			for arg in args {
				arg_vals << json.Any(arg)
			}
			edge_map['args'] = json.Any(arg_vals)
		}
		if exts := eo.extensions {
			mut ext_vals := []json.Any{}
			for ext in exts {
				ext_vals << json.Any(ext)
			}
			edge_map['extensions'] = json.Any(ext_vals)
		}
		if bin := eo.binary {
			edge_map['binary'] = json.Any(bin)
		}
		m['ms:edgeOptions'] = json.Any(edge_map)
	}

	return NewSessionParams{
		capabilities: NewSessionCaps{
			always_match: m
			first_match: none
		}
	}
}
