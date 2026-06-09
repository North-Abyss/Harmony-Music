import sys, json

data = json.load(sys.stdin)
contents = data.get('contents', {})
tabs = contents.get('tabbedSearchResultsRenderer', {}).get('tabs', [])
if tabs:
    sections = tabs[0]['tabRenderer']['content'].get('sectionListRenderer', {}).get('contents', [])
    for sec in sections:
        if 'itemSectionRenderer' in sec:
            for item in sec['itemSectionRenderer'].get('contents', []):
                if 'musicResponsiveListItemRenderer' in item:
                    item_data = item['musicResponsiveListItemRenderer']
                    title = 'N/A'
                    if 'flexColumns' in item_data and len(item_data['flexColumns']) > 0:
                        text_obj = item_data['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']['text']
                        if 'runs' in text_obj:
                            title = text_obj['runs'][0].get('text', 'N/A')
                    subtitles = []
                    if 'flexColumns' in item_data and len(item_data['flexColumns']) > 1:
                        text_obj = item_data['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']['text']
                        if 'runs' in text_obj:
                            subtitles = [r.get('text', '') for r in text_obj['runs']]
                    print(f'{title} - {subtitles}')
