import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:elliptic/elliptic.dart';
import 'package:shelf_router/shelf_router.dart';
import '../connect/par_ad_rimor.dart';
import '../exempla/connexa_liber_expressi.dart';
import '../exempla/errors.dart';
import '../exempla/gladiator.dart';
import '../exempla/obstructionum.dart';
import '../exempla/pera.dart';
import '../exempla/petitio/incipit_pugna.dart';
import '../exempla/telum.dart';
import '../exempla/transactio.dart';
import '../connect/pervideas_to_pervideas.dart';
import 'package:shelf/shelf.dart';
import 'package:tuple/tuple.dart';
import '../exempla/constantes.dart';
import '../exempla/utils.dart';
import 'package:collection/collection.dart';
import '../server.dart';
// Directory directory;
// late String gladiatorId;
// late int gladiatorIndex;
// late String gladiatorPrivateKey;
// P2P p2p;
// Aboutconfig aboutconfig;
// List<Isolate> confussuses;
// bool isSalutaris;
// Map<String, Isolate> propterIsolates;
// Map<String, Isolate> liberTxIsolates;
// Map<String, Isolate> fixumTxIsolates;
// Map<String, Isolate> humanifyIsolates;
// Map<String, Isolate> scanIsolates;
// Map<String, Isolate> cashExIsolates;

Future<Response> fossorConfussus(Request req) async {
  bool estFurca = bool.parse(req.params['furca']!);
  try {
    IncipitPugna ip =
        IncipitPugna.fromJson(json.decode(await req.readAsString()));
    Directory directory =
        Directory('vincula/${argumentis!.obstructionumDirectorium}');
    List<Obstructionum> lo = await Obstructionum.getBlocks(directory);
    if (!File('${directory.path}/${Constantes.caudices}0.txt').existsSync()) {
      return Response.badRequest(
          body: json.encode({
        "code": 0,
        "nuntius": "adhuc expectans incipio obstructionum",
        "message": "Still waiting on incipio block"
      }));
    }
    // so the thread is stull running while the block already is mined so stop the thread from spinning if successful
    Obstructionum priorObstructionum =
        await Obstructionum.acciperePrior(directory);
    ReceivePort acciperePortus = ReceivePort();
    Gladiator? gladiatorOppugnare =
        await Obstructionum.grabGladiator(ip.gladiatorIdentitatis!, lo);
    if (gladiatorOppugnare == null) {
      return Response.badRequest(
          body: json.encode({
        "code": 1,
        "nuntius": "Gladiator iam victus aut non inveni",
        "message": "Gladiator already defeaten or not found"
      }));
    }
    List<Transactio> fixumTxs = [];
    List<Transactio> liberTxs = [];
    liberTxs = Transactio.grab(par!.liberTransactions);
    for (String acc in gladiatorOppugnare
        .interioreGladiator.outputs[ip.primis! ? 0 : 1].rationibus
        .map((e) => e.interiorePropter.publicaClavis)) {
      final balance = await Pera.statera(true, acc, lo);
      if (balance > BigInt.zero) {
        liberTxs.add(Transactio.burn(await Pera.ardeat(
            PrivateKey.fromHex(Pera.curve(), ip.privatusClavis!),
            acc,
            priorObstructionum.probationem,
            balance,
            lo)));
      }
    }
    Tuple2<InterioreTransactio?, InterioreTransactio?> transform =
        await Pera.transformFixum(
            ip.privatusClavis!, par!.liberTransactions, lo);
    if (transform.item1 != null) {
      print(transform.item1!.toJson());
      liberTxs.add(Transactio.nullam(transform.item1!));
    }
    if (transform.item2 != null) {
      print(transform.item2!.toJson());
      fixumTxs.add(Transactio.nullam(transform.item2!));
    }
    List<String> ltum = [];
    liberTxs.map((lt) => lt.interioreTransactio.identitatis).forEach(ltum.add);
    liberTxs.addAll(Transactio.grab(par!.liberTransactions
        .where((wlt) => wlt.interioreTransactio.probatur == true)));
    fixumTxs.addAll(Transactio.grab(par!.fixumTransactions
        .where((wft) => wft.interioreTransactio.probatur == true)));
    List<ConnexaLiberExpressi> cles = par!.invenireConnexaLiberExpressis(ltum);
    List<Transactio> expressiTxs = par!.expressiTransactions
        .where((et) => cles.any((cle) =>
            et.interioreTransactio.identitatis ==
            cle.interioreConnexaLiberExpressi.expressiIdentitatis))
        .toList();
    List<Telum> impetus = [];
    impetus.addAll(await Pera.maximeArma(true, ip.primis!, true,
        gladiatorOppugnare.interioreGladiator.identitatis, lo));
    impetus.addAll(await Pera.maximeArma(false, ip.primis!, false,
        gladiatorOppugnare.interioreGladiator.identitatis, lo));
    List<Telum> defensiones = [];
    defensiones.addAll(await Pera.maximeArma(true, ip.primis!, false,
        gladiatorOppugnare.interioreGladiator.identitatis, lo));
    defensiones.addAll(await Pera.maximeArma(false, ip.primis!, false,
        gladiatorOppugnare.interioreGladiator.identitatis, lo));
    List<String> gladii = impetus.map((e) => e.telum).toList();
    List<String> scuta = defensiones.map((e) => e.telum).toList();
    final String baseDefensio = await Pera.turpiaGladiatoriaTelum(ip.primis!,
        false, gladiatorOppugnare.interioreGladiator.identitatis, lo);
    final String baseImpetum = await Pera.turpiaGladiatoriaTelum(ip.primis!,
        true, gladiatorOppugnare.interioreGladiator.identitatis, lo);
    scuta.add(baseDefensio);
    gladii.add(baseImpetum);
    scuta.removeWhere((defensio) => gladii.any((ag) => ag == defensio));
    List<int> on = await Obstructionum.utObstructionumNumerus(lo.last);
    BigInt numerus = await Obstructionum.numeruo(on);
    final obstructionumDifficultas = await Obstructionum.utDifficultas(lo);
    List<SiRemotionem> lsr = SiRemotionem.grab(par!.siRemotiones);
    InterioreObstructionum interiore = InterioreObstructionum.confussus(
        estFurca: estFurca,
        obstructionumDifficultas: obstructionumDifficultas.length,
        divisa: (numerus / await Obstructionum.utSummaDifficultas(lo)),
        forumCap: await Obstructionum.accipereForumCap(lo),
        liberForumCap: await Obstructionum.accipereForumCapLiberFixum(true, lo),
        fixumForumCap:
            await Obstructionum.accipereForumCapLiberFixum(false, lo),
        summaObstructionumDifficultas:
            await Obstructionum.utSummaDifficultas(lo),
        obstructionumNumerus: on,
        producentis: argumentis!.publicaClavis,
        priorProbationem: priorObstructionum.probationem,
        gladiator: Gladiator.nullam(InterioreGladiator.ce(
            input: await InterioreGladiator.cegi(
                ip.primis!, ip.privatusClavis!, ip.gladiatorIdentitatis!, lo))),
        liberTransactions: liberTxs,
        fixumTransactions: fixumTxs,
        expressiTransactions: [],
        connexaLiberExpressis: cles,
        siRemotiones: lsr,
        prior: priorObstructionum);
    stamina.confussusThreads.add(await Isolate.spawn(
        Obstructionum.confussus,
        List<dynamic>.from(
            [interiore, scuta, acciperePortus.sendPort])));
    acciperePortus.listen((nuntius) async {
      Obstructionum obstructionum = nuntius as Obstructionum;
      InFieriObstructionum ifo = obstructionum.inFieriObstructionum();
      ifo.gladiatorIdentitatum.forEach((gi) =>
          isolates.propterIsolates[gi]?.kill(priority: Isolate.immediate));
      ifo.liberTransactions.forEach((lt) =>
          isolates.liberTxIsolates[lt]?.kill(priority: Isolate.immediate));
      ifo.fixumTransactions.forEach((ft) =>
          isolates.fixumTxIsolates[ft]?.kill(priority: Isolate.immediate));
      par!.removePropters(ifo.gladiatorIdentitatum);
      par!.removeLiberTransactions(ifo.liberTransactions);
      par!.removeFixumTransactions(ifo.fixumTransactions);
      par!.removeConnexaLiberExpressis(ifo.connexaLiberExpressis);
      par!.syncBlock(obstructionum);
    });
    return Response.ok(json.encode({
      "nuntius": "coepi confussus miner",
      "message": "started confussus miner",
      "threads": stamina.confussusThreads.length
    }));
  } on BadRequest catch (e) {
    return Response.badRequest(body: json.encode(e.toJson()));
  }
}

Future<Response> confussusThreads(Request req) async {
  return Response.ok(json.encode({
    "relatorum": stamina.confussusThreads.length,
    "threads": stamina.confussusThreads.length
  }));
}

Future<Response> prohibereConfussus(Request req) async {
  for (int i = 0; i < stamina.efectusThreads.length; i++) {
    stamina.confussusThreads[i].kill(priority: Isolate.immediate);
  }
  return Response.ok(json.encode({
    "nuntius": "bene substitit confussus miner",
    "message": "succesfully stopped confussus miner",
  }));
}