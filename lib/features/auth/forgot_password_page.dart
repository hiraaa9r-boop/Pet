import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget { const ForgotPasswordPage({super.key}); @override State<ForgotPasswordPage> createState()=>_ForgotPasswordPageState();}
class _ForgotPasswordPageState extends State<ForgotPasswordPage>{
  final _email=TextEditingController(); bool _sending=false;
  Future<void> _send() async {
    final email = _email.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un\'email'), backgroundColor: Colors.red)
      );
      return;
    }
    
    setState(()=>_sending=true);
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email di reset inviata! Controlla la tua casella.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          )
        );
        context.pop();
      }
    } on FirebaseAuthException catch(e){
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Nessun utente trovato con questa email';
          break;
        case 'invalid-email':
          errorMessage = 'Email non valida';
          break;
        default:
          errorMessage = e.message ?? 'Errore invio email';
      }
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red)
        );
      }
    } finally { if(mounted) setState(()=>_sending=false); }
  }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Recupera password')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children:[
              TextField(controller:_email, decoration: const InputDecoration(labelText:'Email')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton(onPressed:_sending?null:_send,
                child:_sending?const SizedBox(height:16,width:16,child:CircularProgressIndicator(strokeWidth:2)):const Text('Invia link'))),
            ]),
          ),
        ),
      ),
    );
  }
}
