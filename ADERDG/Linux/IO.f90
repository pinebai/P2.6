SUBROUTINE WriteDataGnuplot
  USE typesDef   
  USE ISO_C_BINDING
  IMPLICIT NONE 
  CHARACTER(LEN=200) :: Title,ScratchDir, VarString   
  CHARACTER(LEN=10)  :: VarName(nVar) 
  CHARACTER(LEN=10)  :: cmyrank 
  INTEGER            :: i,j,ii,jj,c,nc,iRet,iDim,iErr 
  REAL               :: QN(nVar),VN(nVar),Vav(nVar),Vmin(nVar),ldx(d),lx0(d),lxb(d),ux(nVar),uy(nVar)
  REAL               :: LocNode(nVar,(N+1)**nDim), GradNode(nVar,(N+1)**nDim,d),  xvec(d) 
  INTEGER            :: nSubNodes, nPlotElem, nSubPlotElem, nRealNodes, ZoneType, nVertex, nDOFs   
  REAL(8)            :: loctime 
  REAL*4, POINTER    :: DataArray(:,:),TempArray(:) 
  POINTER   (NullPtr,Null)
  Integer*4 Null(*)
  !
  nVertex = 2**nDim 
  !
  NullPtr = 0 
  nPlotElem =  0
  nSubPlotElem = 0
  nRealNodes = 0  
  DO i = 1, nElem
     nPlotElem = nPlotElem + 1
     nSubPlotElem = nSubPlotElem + N**nDim  
     nSubNodes = (N+1)**nDim  
     nRealNodes = nRealNodes + nSubNodes 
  ENDDO
  ALLOCATE(DataArray(nRealNodes,nDim+nVar+1))  

  nDOFs = PRODUCT(nDOF(1:nDim)) 
  c = 0 
  
  OPEN(31,file='rho.dat',status='unknown',position='append')
  OPEN(32,file='v.dat',status='unknown',position='append')
  OPEN(33,file='p.dat',status='unknown',position='append')
  WRITE(31,227) time
  WRITE(32,227) time
  WRITE(33,227) time  
  !
  DO i = 1, nElem      
    LocNode = MATMUL( RESHAPE( uh(:,:,:,:,i), (/ nVar, nDOFs /) ), SubOutputMatrix(1:nDOFs,1:(N+1)**nDim) ) 

    lx0 = x(:,tri(1,i)) 
    DO j = 1, (N+1)**nDim  
        QN(:) = LocNode(:,j) 
        xvec = lx0 + allsubxi(:,j)*dx 
        CALL PDECons2Prim(VN,QN,iErr)
        c = c + 1 
        DataArray(c,:) = (/ xvec(1:nDim), VN, REAL(i) /)   
        SELECT CASE(nDim)
        CASE(1)
           WRITE(31,321) xvec(1), VN(1)
           WRITE(32,321) xvec(1), VN(2)
           WRITE(33,321) xvec(1), VN(5)
        CASE(2)
           WRITE(31,322) xvec(1), xvec(2), VN(1)
        CASE(3)
           WRITE(31,323) xvec(1), xvec(2), xvec(3), VN(1)
        ENDSELECT   
    ENDDO
  ENDDO
  WRITE(31,110);WRITE(32,110);WRITE(33,110)
  CLOSE(31);CLOSE(32);CLOSE(33)  
  
  DEALLOCATE(DataArray)  

110 FORMAT(' ')  
227 format('"Time = ',E13.6)  
321 FORMAT(1x,2(E21.12,1x))
322 FORMAT(1x,3(E21.12,1x))
323 FORMAT(1x,4(E21.12,1x))
    
END SUBROUTINE WriteDataGnuplot
    
