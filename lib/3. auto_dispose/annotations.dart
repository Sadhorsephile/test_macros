
const disposeMethod = 'dispose';
const closeMethod = 'close';
const cancelMethod = 'cancel';

const disposableAnnotationName = 'disposable';
const closableAnnotationName = 'closable';
const cancelableAnnotationName = 'cancelable';
const customDisposableAnnotationName = 'Disposable';
const customDisposableFieldName = 'disposeMethodName';


const disposable = Disposable(disposeMethod);
const closable = Disposable(closeMethod);
const cancelable = Disposable(cancelMethod);

class Disposable {
  final String disposeMethodName;
  const Disposable(this.disposeMethodName);
}