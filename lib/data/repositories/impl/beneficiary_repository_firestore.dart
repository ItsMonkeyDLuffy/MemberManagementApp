import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/beneficiary_repository.dart';
import '../../models/beneficiary_model.dart';

class BeneficiaryRepositoryFirestore implements BeneficiaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addBeneficiary(BeneficiaryModel beneficiary) async {
    // We let Firestore generate the ID, but we save the 'user_id' manually
    await _firestore.collection('beneficiaries').add(beneficiary.toMap());
  }

  @override
  Future<List<BeneficiaryModel>> getBeneficiaries(String userId) async {
    final snapshot = await _firestore
        .collection('beneficiaries')
        .where(
          'user_id',
          isEqualTo: userId,
        ) // SQL equivalent: SELECT * WHERE user_id = X
        .get();

    return snapshot.docs
        .map((doc) => BeneficiaryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> deleteBeneficiary(String beneficiaryId) async {
    await _firestore.collection('beneficiaries').doc(beneficiaryId).delete();
  }
}
