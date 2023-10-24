import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:isolate';
import 'package:hex/hex.dart';
import 'package:tuple/tuple.dart';
import '../auxiliatores/print.dart';
import '../server.dart';
import './utils.dart';
import './obstructionum.dart';
import 'package:elliptic/elliptic.dart';
import 'package:ecdsa/ecdsa.dart';
import './pera.dart';
import './constantes.dart';

enum TransactioSignificatio { regularis, ardeat, transform, praemium, expressi }

extension TransactioSignificatioFromJson on TransactioSignificatio {
  static fromJson(String name) {
    switch (name) {
      case 'regularis':
        return TransactioSignificatio.regularis;
      case 'ardeat':
        return TransactioSignificatio.ardeat;
      case 'transform':
        return TransactioSignificatio.transform;
      case 'praemium':
        return TransactioSignificatio.praemium;
      case 'expressi':
        return TransactioSignificatio.expressi;
    }
  }
}

enum TransactioGenus { liber, fixum, expressi }

class TransactioInput {
  final int index;
  final String signature;
  final String transactioIdentitatis;
  TransactioInput(this.index, this.signature, this.transactioIdentitatis);
  Map<String, dynamic> toJson() => {
        JSON.index: index,
        JSON.signature: signature,
        JSON.transactioIdentitatis: transactioIdentitatis
      };
  TransactioInput.fromJson(Map<String, dynamic> jsoschon)
      : index = int.parse(jsoschon[JSON.index].toString()),
        signature = jsoschon[JSON.signature].toString(),
        transactioIdentitatis = jsoschon[JSON.transactioIdentitatis].toString();
}

class TransactioOutput {
  final String publicaClavis;
  final BigInt pod;
  TransactioOutput(this.publicaClavis, this.pod);
  TransactioOutput.praemium(this.publicaClavis)
      : pod = Constantes.obstructionumPraemium;

  Map<String, dynamic> toJson() => {
        JSON.publicaClavis: publicaClavis,
        JSON.pod: pod.toString(),
      }..removeWhere((key, value) => value == null);
  TransactioOutput.fromJson(Map<String, dynamic> jsoschon)
      : publicaClavis = jsoschon[JSON.publicaClavis].toString(),
        pod = BigInt.parse(jsoschon[JSON.pod].toString());
}

class SiRemotionemInput {
  String signatureInput;
  String identiatisInput;
  SiRemotionemInput(this.signatureInput, this.identiatisInput);
  Map<String, dynamic> toJson() => {
        JSON.signatureInput: signatureInput,
        JSON.identitatisInput: identiatisInput
      };
  SiRemotionemInput.fromJson(Map<String, dynamic> map)
      : signatureInput = map[JSON.signatureInput],
        identiatisInput = map[JSON.identitatisInput];
}

class SiRemotionemOutput {
  String habereIus;
  String debetur;
  String identitatisOutput;
  BigInt pod;
  SiRemotionemOutput(
      this.habereIus, this.debetur, this.identitatisOutput, this.pod);

  SiRemotionemOutput.fromJson(Map<String, dynamic> map)
      : habereIus = map[JSON.habereIus],
        debetur = map[JSON.debetur],
        identitatisOutput = map[JSON.identitatisOutput],
        pod = BigInt.parse(map[JSON.pod].toString());

  Map<String, dynamic> toJson() => {
        JSON.habereIus: habereIus,
        JSON.debetur: debetur,
        JSON.identitatisOutput: identitatisOutput,
        JSON.pod: pod.toString()
      };
}

class InterioreSiRemotionem {
  bool liber;
  SiRemotionemOutput? siRemotionemOutput;
  SiRemotionemInput? siRemotionemInput;
  String identitatisInterioreSiRemotionem;
  String signatureInterioreSiRemotionem;
  BigInt nonce;
  mine() {
    nonce += BigInt.one;
  }

  InterioreSiRemotionem(this.liber, String ex, this.siRemotionemOutput)
      : identitatisInterioreSiRemotionem = Utils.randomHex(64),
        nonce = BigInt.zero,
        signatureInterioreSiRemotionem = Utils.signum(
            PrivateKey.fromHex(Pera.curve(), ex), siRemotionemOutput);

  InterioreSiRemotionem.fromJson(Map<String, dynamic> map)
      : liber = map[JSON.liber],
        siRemotionemInput = map[JSON.siRemotionemInput] != null
            ? SiRemotionemInput.fromJson(
                map[JSON.siRemotionemInput] as Map<String, dynamic>)
            : null,
        siRemotionemOutput = map[JSON.siRemotionemOutput] != null
            ? SiRemotionemOutput.fromJson(
                map[JSON.siRemotionemOutput] as Map<String, dynamic>)
            : null,
        identitatisInterioreSiRemotionem =
            map[JSON.identitatisInterioreSiRemotionem],
        nonce = BigInt.parse(map[JSON.nonce].toString()),
        signatureInterioreSiRemotionem =
            map[JSON.signatureInterioreSiRemotionem];
  Map<String, dynamic> toJson() => {
        JSON.liber: liber,
        JSON.siRemotionemInput: siRemotionemInput?.toJson(),
        JSON.siRemotionemOutput: siRemotionemOutput?.toJson(),
        JSON.identitatisInterioreSiRemotionem: identitatisInterioreSiRemotionem,
        JSON.signatureInterioreSiRemotionem: signatureInterioreSiRemotionem,
        JSON.nonce: nonce.toString()
      };

  bool cognoscere() {
    return Utils.cognoscereSiRemotionem(
        PublicKey.fromHex(Pera.curve(), siRemotionemOutput!.debetur),
        Signature.fromASN1Hex(signatureInterioreSiRemotionem),
        siRemotionemOutput!);
  }
}

class SiRemotionem {
  String probationem;
  InterioreSiRemotionem interioreSiRemotionem;
  SiRemotionem(this.probationem, this.interioreSiRemotionem);
  SiRemotionem.summitto(this.interioreSiRemotionem)
      : probationem = HEX.encode(sha512
            .convert(utf8.encode(json.encode(interioreSiRemotionem.toJson())))
            .bytes);

  SiRemotionem.fromJson(Map<String, dynamic> map)
      : probationem = map[JSON.probationem],
        interioreSiRemotionem = InterioreSiRemotionem.fromJson(
            map[JSON.interioreSiRemotionem] as Map<String, dynamic>);
  Map<String, dynamic> toJson() => {
        JSON.probationem: probationem,
        JSON.interioreSiRemotionem: interioreSiRemotionem.toJson(),
      };

  bool validateProbationem() {
    if (probationem !=
        HEX.encode(sha512
            .convert(utf8.encode(json.encode(interioreSiRemotionem.toJson())))
            .bytes)) {
      return false;
    }
    return true;
  }

  bool seligeSignatureAbMittente() {
    return Utils.cognoscereSiRemotionem(
        PublicKey.fromHex(
            Pera.curve(), interioreSiRemotionem.siRemotionemOutput!.debetur),
        Signature.fromASN1Hex(
            interioreSiRemotionem.signatureInterioreSiRemotionem),
        interioreSiRemotionem.siRemotionemOutput!);
  }

  Future<bool> remotumEst() async {
    Directory directorium = Directory(
        '${Constantes.vincula}/${argumentis!.obstructionumDirectorium}');
    List<Obstructionum> lo = await Obstructionum.getBlocks(directorium);
    List<Transactio> ltlt = [];
    lo
        .map((mo) => mo.interioreObstructionum.liberTransactions)
        .forEach(ltlt.addAll);
    if (ltlt.any((alt) =>
        alt.interioreTransactio.identitatis ==
        interioreSiRemotionem.siRemotionemOutput!.identitatisOutput)) {
      return false;
    }
    List<Transactio> ltft = [];
    lo
        .map((mo) => mo.interioreObstructionum.fixumTransactions)
        .forEach(ltft.addAll);
    if (ltft.any((alt) =>
        alt.interioreTransactio.identitatis ==
        interioreSiRemotionem.siRemotionemOutput!.identitatisOutput)) {
      return false;
    }
    List<SiRemotionem> lsr = [];
    lo.map((mo) => mo.interioreObstructionum.siRemotiones).forEach(lsr.addAll);
    if (lsr.any((asr) =>
        asr.interioreSiRemotionem.identitatisInterioreSiRemotionem ==
        interioreSiRemotionem.identitatisInterioreSiRemotionem)) {
      return false;
    }
    return true;
  }

  Future<bool> nonHabetInitus() async {
    Directory directorium = Directory(
        '${Constantes.vincula}/${argumentis!.obstructionumDirectorium}');
    List<Obstructionum> lo = await Obstructionum.getBlocks(directorium);
    List<SiRemotionem> lsr = [];
    lo.map((mo) => mo.interioreObstructionum.siRemotiones).forEach(lsr.addAll);
    List<SiRemotionemInput> lsri =
        lsr.map((msr) => msr.interioreSiRemotionem.siRemotionemInput!).toList();

    List<String> inputIdentitatum = [];
    lsri.map((sri) => sri.identiatisInput).forEach(inputIdentitatum.add);
    return !lsri.any((asri) => inputIdentitatum
        .contains(interioreSiRemotionem.identitatisInterioreSiRemotionem));
  }

  Future<bool> valetInitus() async {
    if (interioreSiRemotionem.siRemotionemInput == null) {
      return true;
    }
    return false;
  }

  static void quaestum(List<dynamic> argumentis) {
    InterioreSiRemotionem interiore = argumentis[0] as InterioreSiRemotionem;
    SendPort mitte = argumentis[1] as SendPort;
    String probationem = '';
    int zeros = 1;
    while (true) {
      do {
        interiore.mine();
        probationem = HEX.encode(
            sha512.convert(utf8.encode(json.encode(interiore.toJson()))).bytes);
      } while (!probationem.startsWith('0' * zeros));
      zeros += 1;
      mitte.send(SiRemotionem(probationem, interiore));
    }
  }

  static List<SiRemotionem> grab(Iterable<SiRemotionem> isr) {
    List<SiRemotionem> reditus = [];
    for (int i = 128; i > 0; i--) {
      if (isr.any((aisr) => aisr.probationem.startsWith('0' * i))) {
        if (reditus.length < Constantes.txCaudice) {
          reditus.addAll(isr.where((wsr) =>
              wsr.probationem.startsWith('0' * i) && !reditus.contains(wsr)));
        } else {
          break;
        }
      }
    }
    return reditus;
  }
}

class InterioreTransactio {
  final bool liber;
  bool probatur;
  final TransactioSignificatio transactioSignificatio;
  SiRemotionem? siRemotionem;
  final List<TransactioInput> inputs;
  final List<TransactioOutput> outputs;
  final String identitatis;
  BigInt nonce;
  InterioreTransactio(
      {required String ex,
      required this.liber,
      required this.identitatis,
      required this.transactioSignificatio,
      required this.inputs,
      required this.outputs,
      required SiRemotionemOutput sro})
      : probatur = false,
        nonce = BigInt.zero,
        siRemotionem =
            SiRemotionem.summitto(InterioreSiRemotionem(liber, ex, sro));

  // siRemotionem = SiRemotionem.exTransactio(ex.toHex(),
  //     InterioreSiRemotionem(to, ex.toHex(), identitatis, BigInt.zero));
  InterioreTransactio.praemium(String producentis)
      : liber = true,
        probatur = false,
        transactioSignificatio = TransactioSignificatio.praemium,
        siRemotionem = null,
        inputs = [],
        outputs = [TransactioOutput.praemium(producentis)],
        nonce = BigInt.zero,
        identitatis = Utils.randomHex(64);

  InterioreTransactio.transform({
    required bool liber,
    required this.inputs,
    required this.outputs,
  })  : liber = liber,
        probatur = false,
        transactioSignificatio = TransactioSignificatio.transform,
        siRemotionem = null,
        identitatis = Utils.randomHex(64),
        nonce = BigInt.zero;

  mine() {
    nonce += BigInt.one;
  }

  Map<String, dynamic> toJson() => {
        JSON.liber: liber,
        JSON.probatur: probatur,
        JSON.transactioSignificatio: transactioSignificatio.name.toString(),
        JSON.inputs: inputs.map((i) => i.toJson()).toList(),
        JSON.outputs: outputs.map((o) => o.toJson()).toList(),
        JSON.identitatis: identitatis,
        JSON.nonce: nonce.toString(),
        JSON.siRemotionem: siRemotionem?.toJson()
      }..removeWhere((key, value) => value == null);
  InterioreTransactio.fromJson(Map<String, dynamic> jsoschon)
      : liber = jsoschon[JSON.liber],
        probatur = jsoschon[JSON.probatur],
        transactioSignificatio = TransactioSignificatioFromJson.fromJson(
                jsoschon[JSON.transactioSignificatio].toString())
            as TransactioSignificatio,
        siRemotionem = jsoschon[JSON.siRemotionem] == null
            ? null
            : SiRemotionem.fromJson(
                jsoschon[JSON.siRemotionem] as Map<String, dynamic>),
        inputs = List<TransactioInput>.from((jsoschon[JSON.inputs]
                as List<dynamic>)
            .map((i) => TransactioInput.fromJson(i as Map<String, dynamic>))),
        outputs = List<TransactioOutput>.from(jsoschon[JSON.outputs]
            .map((o) => TransactioOutput.fromJson(o as Map<String, dynamic>))),
        identitatis = jsoschon[JSON.identitatis].toString(),
        nonce = BigInt.parse(jsoschon[JSON.nonce].toString());
}

class Transactio {
  late String probationem;
  final InterioreTransactio interioreTransactio;
  Transactio(this.probationem, this.interioreTransactio);
  Transactio.fromJson(Map<String, dynamic> jsoschon)
      : probationem = jsoschon[JSON.probationem].toString(),
        interioreTransactio = InterioreTransactio.fromJson(
            jsoschon[JSON.interioreTransactio] as Map<String, dynamic>);
  Transactio.nullam(this.interioreTransactio)
      : probationem = HEX.encode(sha512
            .convert(utf8.encode(json.encode(interioreTransactio.toJson())))
            .bytes);
  Transactio.praemium(String producentis)
      : interioreTransactio = InterioreTransactio.praemium(producentis) {
    probationem = HEX.encode(sha512
        .convert(utf8.encode(json.encode(interioreTransactio.toJson())))
        .bytes);
  }
  static void quaestum(List<dynamic> argumentis) {
    InterioreTransactio interiore = argumentis[0] as InterioreTransactio;
    SendPort mitte = argumentis[1] as SendPort;
    String probationem = '';
    int zeros = 1;
    while (true) {
      do {
        interiore.mine();
        probationem = HEX.encode(
            sha512.convert(utf8.encode(json.encode(interiore.toJson()))).bytes);
      } while (!probationem.startsWith('0' * zeros));
      zeros += 1;
      mitte.send(Transactio(probationem, interiore));
    }
  }

  Transactio.burn(this.interioreTransactio)
      : probationem = HEX.encode(sha512
            .convert(utf8.encode(json.encode(interioreTransactio.toJson())))
            .bytes);
  bool validateBlockreward() {
    if (interioreTransactio.outputs.length != 1) {
      return false;
    }
    if (interioreTransactio.outputs[0].pod !=
        Constantes.obstructionumPraemium) {
      return false;
    }
    if (interioreTransactio.inputs.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<bool> validateBurn(Directory dir) async {
    List<Obstructionum> obs = await Obstructionum.getBlocks(dir);
    BigInt spendable = BigInt.zero;
    for (TransactioInput input in interioreTransactio.inputs) {
      Obstructionum prevObs = obs.singleWhere((ob) =>
          ob.interioreObstructionum.liberTransactions.any((liber) =>
              liber.interioreTransactio.identitatis ==
              input.transactioIdentitatis));
      TransactioOutput output = prevObs.interioreObstructionum.liberTransactions
          .singleWhere((liber) =>
              liber.interioreTransactio.identitatis ==
              input.transactioIdentitatis)
          .interioreTransactio
          .outputs[input.index];
      spendable = output.pod;
    }
    BigInt spended = BigInt.zero;
    for (TransactioOutput output in interioreTransactio.outputs) {
      spended += output.pod;
    }
    if (spendable > spended) {
      return false;
    }
    return true;
  }

  static Future<bool> validateArdeat(
      List<TransactioInput> tins, List<Obstructionum> lo) async {
    List<List<TransactioOutput>> toss = [];
    lo
        .map((obs) => obs.interioreObstructionum.liberTransactions
            .where((lt) =>
                lt.interioreTransactio.transactioSignificatio ==
                    TransactioSignificatio.ardeat &&
                tins
                    .map((ti) => ti.transactioIdentitatis)
                    .contains(lt.interioreTransactio.identitatis))
            .map((lt) => lt.interioreTransactio.outputs))
        .forEach(toss.addAll);
    List<int> tii = tins.map((ti) => ti.index).toList();
    List<String> publicaClavises = [];
    for (List<TransactioOutput> tos in toss) {
      for (int i = 0; i < tii.length; i++) {
        publicaClavises.add(tos[tii[i]].publicaClavis);
      }
    }
    List<Tuple2<String, BigInt>> ssb = [];
    for (List<TransactioOutput> tos in toss) {
      for (int i = 0; i < tii.length; i++) {
        ssb.add(Tuple2(tos[tii[i]].publicaClavis, tos[tii[i]].pod));
      }
    }
    List<String> pcs = [];
    List<Tuple2<String, BigInt>> lsssb = [];
    for (int i = 0; i < lsssb.length; i++) {
      if (!pcs.contains(lsssb[i].item1)) {
        pcs.add(lsssb[i].item1);
        lsssb.add(Tuple2(lsssb[i].item1, lsssb[i].item2));
      } else {
        BigInt sta =
            lsssb.singleWhere((pc) => pc.item1 == lsssb[i].item1).item2 +
                lsssb[i].item2;
        lsssb.removeAt(i);
        lsssb.add(Tuple2(lsssb[i].item1, sta));
      }
    }
    for (Tuple2<String, BigInt> sssb in lsssb) {
      if (sssb.item2 == await Pera.statera(true, sssb.item1, lo)) {
        continue;
      } else {
        return false;
      }
    }
    return true;
  }

  bool isFurantur() {
    return interioreTransactio.outputs
        .any((element) => element.pod < BigInt.zero);
  }

  Future<bool> convalidandumTransaction(
      String? victor, TransactioGenus tg, List<Obstructionum> lo) async {
    BigInt spendable = BigInt.zero;
    for (TransactioInput input in interioreTransactio.inputs) {
      switch (tg) {
        case TransactioGenus.liber:
          {
            Transactio transactio = lo
                .singleWhere((obs) => obs
                    .interioreObstructionum.liberTransactions
                    .any((transactions) =>
                        transactions.interioreTransactio.identitatis ==
                        input.transactioIdentitatis))
                .interioreObstructionum
                .liberTransactions
                .singleWhere((transactio) =>
                    transactio.interioreTransactio.identitatis ==
                    input.transactioIdentitatis);
            spendable +=
                transactio.interioreTransactio.outputs[input.index].pod;
            switch (transactio.interioreTransactio.transactioSignificatio) {
              case TransactioSignificatio.ardeat:
              case TransactioSignificatio.expressi:
              case TransactioSignificatio.regularis:
                {
                  if (!estSominusPecuniae(input, transactio)) {
                    return false;
                  }
                  break;
                }
              case TransactioSignificatio.transform:
                {
                  if (!estSubscriptioneVictor(victor!, input, transactio)) {
                    return false;
                  }
                  break;
                }
              default:
                break;
            }
          }
        case TransactioGenus.expressi:
          {
            Transactio transactio = lo
                .singleWhere((obs) => obs
                    .interioreObstructionum.liberTransactions
                    .any((transactions) =>
                        transactions.interioreTransactio.identitatis ==
                        input.transactioIdentitatis))
                .interioreObstructionum
                .liberTransactions
                .singleWhere((transactio) =>
                    transactio.interioreTransactio.identitatis ==
                    input.transactioIdentitatis);
            spendable +=
                transactio.interioreTransactio.outputs[input.index].pod;
            if (!estSominusPecuniae(input, transactio)) {
              Print.nota(
                  nuntius: 'non est dominus pecuniae',
                  message: 'is not the owner of money');
              return false;
            } else {
              return true;
            }
          }
        case TransactioGenus.fixum:
          {
            Transactio transactio = lo
                .singleWhere((obs) => obs
                    .interioreObstructionum.fixumTransactions
                    .any((transactions) =>
                        transactions.interioreTransactio.identitatis ==
                        input.transactioIdentitatis))
                .interioreObstructionum
                .fixumTransactions
                .singleWhere((transactio) =>
                    transactio.interioreTransactio.identitatis ==
                    input.transactioIdentitatis);
            spendable +=
                transactio.interioreTransactio.outputs[input.index].pod;
            if (!estSominusPecuniae(input, transactio) &&
                interioreTransactio.transactioSignificatio !=
                    TransactioSignificatio.transform) {
              Print.nota(
                  nuntius: 'non est dominus pecuniae',
                  message: 'is not the owner of money');
              return false;
            } else {
              return true;
            }
          }
      }
    }
    if (interioreTransactio.transactioSignificatio ==
        TransactioSignificatio.transform) {
      return true;
    }
    BigInt spended = BigInt.zero;
    for (TransactioOutput output in interioreTransactio.outputs) {
      spended += output.pod;
    }
    return spendable == spended;
  }

  bool estSominusPecuniae(TransactioInput input, Transactio transactio) {
    return Utils.cognoscere(
        PublicKey.fromHex(Pera.curve(),
            transactio.interioreTransactio.outputs[input.index].publicaClavis),
        Signature.fromASN1Hex(input.signature),
        transactio.interioreTransactio.outputs[input.index]);
  }

  bool estSubscriptioneVictor(
      String victor, TransactioInput ti, Transactio transactio) {
    return Utils.cognoscere(
        PublicKey.fromHex(Pera.curve(), victor),
        Signature.fromASN1Hex(ti.signature),
        transactio.interioreTransactio.outputs[ti.index]);
  }

  Map<String, dynamic> toJson() => {
        JSON.probationem: probationem,
        JSON.interioreTransactio: interioreTransactio.toJson()
      };
  static List<Transactio> grab(Iterable<Transactio> txs) {
    List<Transactio> reditus = [];
    for (int i = 128; i > 0; i--) {
      if (txs.any((tx) => tx.probationem.startsWith('0' * i))) {
        if (reditus.length < Constantes.txCaudice) {
          reditus.addAll(txs.where((tx) =>
              tx.probationem.startsWith('0' * i) && !reditus.contains(tx)));
        } else {
          break;
        }
      }
    }
    return reditus;
  }

  bool validateProbationem() {
    if (probationem !=
        HEX.encode(sha512
            .convert(utf8.encode(json.encode(interioreTransactio.toJson())))
            .bytes)) {
      return false;
    }
    return true;
  }

  static Future<bool> omnesClavesPublicasDefendi(
      List<TransactioOutput> outputs, List<Obstructionum> lo) async {
    for (TransactioOutput output in outputs) {
      if (!await Pera.isPublicaClavisDefended(output.publicaClavis, lo)) {
        return false;
      }
    }
    return true;
  }

  static Future<bool> inObstructionumCatenae(TransactioGenus tg,
      List<String> identitatump, Directory directorium) async {
    List<Obstructionum> obs = await Obstructionum.getBlocks(directorium);
    List<String> identitatum = [];
    switch (tg) {
      case TransactioGenus.liber:
        {
          obs
              .map((ob) => ob.interioreObstructionum.liberTransactions
                  .map((lt) => lt.interioreTransactio.identitatis))
              .forEach(identitatum.addAll);
          return identitatum
              .every((identitatis) => identitatump.contains(identitatis));
        }
      case TransactioGenus.fixum:
        {
          obs
              .map((ob) => ob.interioreObstructionum.fixumTransactions
                  .map((ft) => ft.interioreTransactio.identitatis))
              .forEach(identitatum.addAll);
          return identitatum
              .every((identitatis) => identitatump.contains(identitatis));
        }
      case TransactioGenus.expressi:
        {
          obs
              .map((ob) => ob.interioreObstructionum.expressiTransactions
                  .map((et) => et.interioreTransactio.identitatis))
              .forEach(identitatum.addAll);
          return identitatum
              .every((identitatis) => identitatump.contains(identitatis));
        }
    }
  }
}