���O����97.2���Afun�Bname_fun�����ô���S�L�A���ڦ��y�L�ץ��F�@��bug�ѤU�N�ݧA�̤F

�ϥ�����linux ubuntu 64bit

lex�ɪ�����---------------------------
�ڧ� �Ʀrreturn NUMBER
�ڧ� #t #freturn BOOL
�H�Ψ�L�H���w�q���r����^�ǧڷQ�n����
�̫��ID������return�^�h�A
�ӪŮ�򴫦橿�����C
�ѤU���r�����D�k�r���|��Xunexpected character�r��
--------------------------------------

yacc�ɪ�����--------------------------
�Ҧ���exp�ڳ��Φs��@��binary tree�̭�

tree��node���|���@��type�O���L�O����operater�άOnumber�άOvariable�A
�p�G�Onumber�A�L��value�N�|�O���L����;�p�G�Ovariable�A�L��name�N�|�O��L���W�r
1.�J��@��operation�ɥL���W�h�N�O(op exp exps) �� (op exp) �N�⥪�k�p�ĩ񦨥��kexp�s��tree�A�ۤv�N�Oop
2.��¹J��ID�ɴN�ۤv�Ovariable�A���k�p�Ĭ���
3.��¹J��NUMBER�ɴN�ۤv�Onumber�A���k�p�Ĭ���
4.����exps�i�H�i�}�A�ڱN���̤������Poperator��exp�A�N�i�H�ھڤ��P��operator�гynode
5.�̫�C�ӿW��exp��exp���|�ܦ��@��tree
6.����ݭn����exp���ȮɡA�ڤ~�|call EvalueTree(exp)�A���覡��X�ȡA��²�檺DFS�N�i�H��X�ӤF�C

�x�s�ܼƪ��覡�s���ܼ�ID�i�ӮɡA�ڴN���L�@��va[vsp]���䤤�@��vsp����l
�bdef_stmt�ɡA�|���ڷ|exp���Ⱥ�X�ӡA�H�ζ��K��exp�s�b�ӦW�r�̭��A�H�Ƥ���ϥθӦW�r�C
��ڦ��W�r�ɡA�ڥ�get_vsp(ID)�N�i�H���D�L��vsp�C

if�������N�O�|����Xtest_exp���ȡA�b��ܭn�Nthen_exp��else_exp�ǤU�h�A�̫�N�ݥL���y�ƤF�C

�bfunction�������A�p�G�S��parameter�A�ڪ�fun_exp�N�٬O��ڨ���exp�ǤU�h�A
�p�G���A�N��i�htree���A������ܼƪ��a�賣����������parameter�A
�p�G�Ofun_name�������A�ڴN�hva[vsp]�A��������exp�A�A�ھڦ��S��parameter���������B�z

error�������ڦۤv�g�Ferror��function�A�i�D�ϥΪ�error���F��O���ӡA
�b�C��operation���w�q���A�]�g�F�p�G�֤Fexp��error�N�i�H�P�_�X�ӤF
--------------------------------------