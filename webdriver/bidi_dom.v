module webdriver

import x.json2 as json

// BiDi DOM node handles and input.setFiles.
//
// BiDi refers to elements by a `sharedId` (a "shared reference"), which is a
// different namespace from the Classic WebDriver element id used by
// find_element/ElementRef/Locator. browsingContext.locateNodes is how you
// obtain a BiDi node handle, which can then be fed to BiDi commands such as
// input.setFiles (file upload).

// BiDiNode is a handle to a DOM node in a browsing context (a BiDi sharedId).
pub struct BiDiNode {
pub:
	shared_id string
}

// locate_nodes finds DOM nodes via BiDi. `using` is a BiDi locator type:
// 'css', 'xpath', or 'innerText'.
pub fn (mut b BiDi) locate_nodes(context string, using string, value string) ![]BiDiNode {
	mut locator := map[string]json.Any{}
	locator['type'] = json.Any(using)
	locator['value'] = json.Any(value)
	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['locator'] = json.Any(locator)
	res := b.send('browsingContext.locateNodes', json.Any(p))!

	mut nodes := []BiDiNode{}
	if ns := res.as_map()['nodes'] {
		for n in ns.as_array() {
			if sid := n.as_map()['sharedId'] {
				nodes << BiDiNode{
					shared_id: sid.str()
				}
			}
		}
	}
	return nodes
}

// locate_node returns the first node matching the locator.
pub fn (mut b BiDi) locate_node(context string, using string, value string) !BiDiNode {
	nodes := b.locate_nodes(context, using, value)!
	if nodes.len == 0 {
		return error('no node matched ${using}=${value}')
	}
	return nodes[0]
}

// set_files sets the selected files on a file <input> (Playwright
// setInputFiles). Paths should be absolute. Pass the target via locate_node.
pub fn (mut b BiDi) set_files(context string, node BiDiNode, files []string) ! {
	mut element := map[string]json.Any{}
	element['sharedId'] = json.Any(node.shared_id)

	mut file_arr := []json.Any{}
	for f in files {
		file_arr << json.Any(f)
	}

	mut p := map[string]json.Any{}
	p['context'] = json.Any(context)
	p['element'] = json.Any(element)
	p['files'] = json.Any(file_arr)
	b.send('input.setFiles', json.Any(p))!
}
