"""Bounded, sequential local advisory reviews; no tools are exposed to models."""
import json
from pathlib import Path
import urllib.request

context = '''We are formalizing OEIS A283508, not assuming its conjecture.
Infinite integer grid, initially only origin ON. Each simultaneous update uses
bit (c+2*k) of 643, where c is center 0/1 and k counts four orthogonal ON neighbors.
Equivalent rule: k=0 OR (c=1 AND k>=3). All-OFF background becomes ON at step 1.
Simulation suggests step 2 is all ON except the 8 cells max(abs(x),abs(y))=1,
and this whole configuration is fixed. Read x=0..n,y=0 at step n, encode as
DECIMAL digits (not base 2). Conjecture: a(n)=(91*10^n-10)/90 for n>0.
OEIS program uses a large finite grid; locality must justify the infinite version.
Linked diagrams say Rule 641, whereas entry and program specify 643.
'''
for model, task in [
    ('qwen3.5:9b', 'Suggest a concise Lean proof decomposition for the fixed configuration and formula. Identify possible mistakes. Do not claim code compiles.'),
    ('gemma3:12b', 'Independently audit the mathematical translation, rule bits, background, indexing, and decimal formula. Identify concrete risks and checks. Be concise.'),
]:
    payload = dict(model=model, prompt=context+task, stream=False,
                   keep_alive=0, options=dict(num_predict=1800, num_ctx=4096, temperature=0.2))
    if model.startswith('qwen'): payload['think'] = False
    name = model.split(':')[0]
    Path('reviews/'+name+'-request.json').write_text(json.dumps(payload, indent=2))
    try:
        req = urllib.request.Request('http://localhost:11434/api/generate',
              data=json.dumps(payload).encode(), headers={'Content-Type':'application/json'})
        with urllib.request.urlopen(req, timeout=300) as response:
            result = json.load(response)
        Path('reviews/'+name+'-response.json').write_text(json.dumps(result, indent=2))
        print(model, result.get('response', ''), flush=True)
    except Exception as exc:
        Path('reviews/'+name+'-error.txt').write_text(str(exc))
        print(model, str(exc), flush=True)
