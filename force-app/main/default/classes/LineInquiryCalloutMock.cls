@isTest
global class LineInquiryCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"kategori":"A","resultater":[{"adresse":{"id":"0a3f50a5-31d5-32b8-e044-0003ba298018","vejnavn":"Risbystræde","adresseringsvejnavn":"Risbystræde","husnr":"19","supplerendebynavn":null,"postnr":"2620","postnrnavn":"Albertslund","status":1,"virkningstart":"2009-11-24T00:50:11.000Z","virkningslut":null,"adgangsadresseid":"0a3f507c-ab89-32b8-e044-0003ba298018","etage":null,"dør":null,"href":"https://api.dataforsyningen.dk/adresser/0a3f50a5-31d5-32b8-e044-0003ba298018"},"aktueladresse":{"id":"0a3f50a5-31d5-32b8-e044-0003ba298018","vejnavn":"Risbystræde","adresseringsvejnavn":"Risbystræde","husnr":"19","supplerendebynavn":null,"postnr":"2620","postnrnavn":"Albertslund","status":1,"virkningstart":"2009-11-24T00:50:11.000Z","virkningslut":null,"adgangsadresseid":"0a3f507c-ab89-32b8-e044-0003ba298018","etage":null,"dør":null,"href":"https://api.dataforsyningen.dk/adresser/0a3f50a5-31d5-32b8-e044-0003ba298018"},"vaskeresultat":{"variant":{"vejnavn":"Risbystræde","husnr":"19","etage":null,"dør":null,"supplerendebynavn":null,"postnr":"2620","postnrnavn":"Albertslund"},"afstand":0,"forskelle":{"vejnavn":0,"husnr":0,"postnr":0,"postnrnavn":0},"parsetadresse":{"vejnavn":"Risbystræde","husnr":"19","postnr":"2620","postnrnavn":"Albertslund"},"ukendtetokens":[],"anvendtstormodtagerpostnummer":null}}]}');
        response.setStatusCode(200);
        return response;
    }
}