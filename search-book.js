// Vercel 서버리스 함수: 브라우저가 아니라 서버에서 알라딘 API를 대신 호출합니다.
// 그래서 TTBKey가 방문자에게 절대 노출되지 않아요.

export default async function handler(req, res) {
  const q = req.query.q;
  if (!q) {
    return res.status(400).json({ error: '검색어(q)가 필요해요.' });
  }

  const ttbKey = (process.env.ALADIN_TTB_KEY || '').trim();

  if (!ttbKey) {
    return res.status(500).json({ error: 'Vercel 환경변수(ALADIN_TTB_KEY)가 설정되지 않았어요.' });
  }

  try {
    const url = `https://www.aladin.co.kr/ttb/api/ItemSearch.aspx?ttbkey=${ttbKey}&Query=${encodeURIComponent(q)}&QueryType=Title&MaxResults=8&start=1&SearchTarget=Book&output=js&Version=20131101&Cover=Big`;
    const aladinRes = await fetch(url);

    if (!aladinRes.ok) {
      const errText = await aladinRes.text();
      return res.status(aladinRes.status).json({ error: '알라딘 API 오류', detail: errText });
    }

    const data = await aladinRes.json();

    if (data.errorCode) {
      return res.status(400).json({ error: '알라딘 API 오류', detail: data.errorMessage });
    }

    const items = (data.item || []).map(it => ({
      title: it.title || '',
      author: it.author || '',
      publisher: it.publisher || '',
      thumbnail: it.cover || '',
      isbn: it.isbn13 || it.isbn || ''
    }));

    res.status(200).json({ items });
  } catch (e) {
    res.status(500).json({ error: '검색 중 오류가 발생했어요.', detail: String(e) });
  }
}
