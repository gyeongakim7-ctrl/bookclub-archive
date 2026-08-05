// Vercel 서버리스 함수: 브라우저가 아니라 서버에서 네이버 API를 대신 호출합니다.
// 그래서 Client ID/Secret이 방문자에게 절대 노출되지 않아요.

function stripTags(s) {
  return (s || '').replace(/<[^>]*>/g, '');
}

export default async function handler(req, res) {
  const q = req.query.q;
  if (!q) {
    return res.status(400).json({ error: '검색어(q)가 필요해요.' });
  }

  const clientId = process.env.NAVER_CLIENT_ID;
  const clientSecret = process.env.NAVER_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    return res.status(500).json({ error: 'Vercel 환경변수(NAVER_CLIENT_ID, NAVER_CLIENT_SECRET)가 설정되지 않았어요.' });
  }

  try {
    const url = `https://openapi.naver.com/v1/search/book.json?query=${encodeURIComponent(q)}&display=8`;
    const naverRes = await fetch(url, {
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret
      }
    });

    if (!naverRes.ok) {
      const errText = await naverRes.text();
      return res.status(naverRes.status).json({ error: '네이버 API 오류', detail: errText });
    }

    const data = await naverRes.json();
    const items = (data.items || []).map(it => ({
      title: stripTags(it.title),
      author: stripTags(it.author),
      publisher: stripTags(it.publisher),
      thumbnail: it.image || '',
      isbn: it.isbn || ''
    }));

    res.status(200).json({ items });
  } catch (e) {
    res.status(500).json({ error: '검색 중 오류가 발생했어요.', detail: String(e) });
  }
}
