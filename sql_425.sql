select m.usuariocriacao_sc, m.numero_sc, m.obs_sc, m.tipo_sc, m.nometipomov_sc,
       m.emissao_sc, m.status_sc, m.status_conclusao_sc, m.codigoprd_sc,
       m.codigoaux_sc, m.codigogrupo_sc, m.nomeprd_sc, m.unprd_sc, m.quantidade_sc,
       m.ccreduzido_sc, m.ccnome_sc, m.dataaprovacao_sc, m.aprovador, m.numero_pd,
       m.tipo_pd, m.nometipomov_pd, m.dataemissao_pd, m.status_pd, m.status_conclusao_pd,
       m.quantidadeoriginal, m.quantidadeareceber, m.quantidadeconcluida, m.numero_oc,
       m.tipo_oc, m.nometipomov_oc, m.dataemissao_oc, m.status_oc, m.status_conclusao_oc,
       m.forncecedor_oc, m.oc_marcaprod, m.dataentrega_oc, m.quantidade_oc, m.quantidadeareceber_oc,
       m.quantidadeconcluida_oc, m.precounitario_oc, m.valorliquidoorig_oc, m.valordesc,
       m.quantidade_nf, m.precounitario_nf, m.valorliquio_nf, m.numero_nf, m.dataentrada_nf,
       m.valorliquido_nf, m.saldo, m.usuario_pims, m.requisicao_erp, m.ospims
      ,m.dt_entrada
      ,m.origempims
      ,m.de_mensagem_int
      ,m.fg_objeto
      ,m.cd_equipto
      ,m.cd_ccusto
      ,m.cd_clasmanu
      ,m.de_clasmanu
      ,tipo_compra_sc

from 
(

select 

sc.reccreatedby usuariocriacao_sc,
       '''' || sc.numeromov numero_sc,
       sc.observacao obs_sc,
       sc.codtmv tipo_sc,
       tm.nome nometipomov_sc,
       sc.dataemissao emissao_sc,
       case_ret_status(sc.status) status_sc,
       case when sc.stsconcluido  is null then ' '
            when sc.stsconcluido  = 'P' then 'Parc. Concluido'
            when sc.stsconcluido  = 'C' then 'Concluido'
            else 'Outro' end status_conclusao_sc,
       '''' || psc.codigoprd codigoprd_sc,
       '''' || psc.codigoauxiliar codigoaux_sc,
       '''' || psc.codtb1fat codigogrupo_sc,
       psc.nomefantasia nomeprd_sc,
       psc.codundcontrole unprd_sc,
       isc.quantidadetotal quantidade_sc,
       '''' || cc.codreduzido ccreduzido_sc,
       cc.nome ccnome_sc,     
       (select decode(nvl(a.tipoaprovacao,0),1, to_char(a.dataaprovacao, 'DD/MM/RRRR HH24:MI:SS'),'') 
        from tmovaprova a, gusuario u 
        where a.idmov = sc.idmov
         and a.codcoligada = sc.codcoligada
         and a.dataaprovacao = (select max (a.dataaprovacao) from tmovaprova a where a.idmov = sc.idmov and a.codcoligada = sc.codcoligada)
         and a.codusuario = u.codusuario) dataaprovacao_sc,
       sc.codven2 aprovador,
       
       pd.numeromov numero_pd,
       pd.codtmv tipo_pd,
       pd.nometmv nometipomov_pd,
       pd.dataemissao dataemissao_pd,
       case_ret_status(pd.status) status_pd,
       case when pd.stsconcluido  is null then ' '
            when pd.stsconcluido  = 'P' then 'Parc. Concluido'
            when pd.stsconcluido  = 'C' then 'Concluido'
            else ' Outro'  end status_conclusao_pd,
        pd.quantidadeoriginal,
        pd.quantidadeareceber,
        pd.quantidadeconcluida,
         
       oc.numeromov numero_oc,
       oc.codtmv tipo_oc,
       oc.nometmv nometipomov_oc,
       oc.dataemissao dataemissao_oc,
       case_ret_status(oc.status) status_oc,
       case when oc.stsconcluido  is null then ' '
            when oc.stsconcluido  = 'P' then 'Parc. Concluido'
            when oc.stsconcluido  = 'C' then 'Concluido'
            else oc.stsconcluido || ' Outro' end status_conclusao_oc,
       oc.nomefantasia forncecedor_oc,
       oc.dataentrega dataentrega_oc,
       oc.quantidadeoriginal quantidade_oc,
       oc.quantidadeareceber quantidadeareceber_oc,
       oc.quantidadeconcluida quantidadeconcluida_oc,
       oc.precounitario precounitario_oc,
       oc.valorliquidoorig valorliquidoorig_oc,
       oc.valordesc,
       oc.descmarca oc_marcaprod,
       
       nf.quantidadetotal quantidade_nf,
       nf.precounitario precounitario_nf,
       nf.valorliquido valorliquio_nf,       
       nf.numeromov numero_nf,
       nf.datamovimento dataentrada_nf,
       nf.valorliquido valorliquido_nf,
       nvl(l.saldofisico2,0) saldo,
       po.cd_usr_dml usuario_pims,
       po.num_docerp requisicao_erp,
       ic.ospims,
       ic.origempims,
       po.de_mensagem_int
      ,h.fg_objeto || '-' || decode(h.fg_objeto,'1','EQUIPTOS','2','AGREGADOS','3','CCUSTO') fg_objeto
      ,h.cd_equipto
      ,h.cd_agreg
      ,h.cd_ccusto
      ,clm.cd_clasmanu
      ,clm.de_clasmanu
      ,mc.tpcompra tipo_compra_sc
      , h.dt_entrada
      
      
           
from tmov sc inner join ttmv tm         on sc.codcoligada         = tm.codcoligada and sc.codtmv = tm.codtmv
             inner join titmmov isc     on sc.codcoligada     = isc.codcoligada  and sc.idmov = isc.idmov  
             left join tmovcompl mc    on sc.codcoligada = mc.codcoligada and sc.idmov = mc.idmov
             left  join titmmovcompl ic on ic.codcoligada = isc.codcoligada  and ic.idmov = isc.idmov  and ic.nseqitmmov = isc.nseqitmmov
             inner join tprd psc        on isc.codcoligada       = psc.codcoligada and isc.idprd = psc.idprd
             left  join gccusto cc      on isc.codcoligada     = cc.codcoligada and isc.codccusto = cc.codccusto
             left  join tprdloc l       on l.codcoligada       = isc.codcoligada and  l.codfilial = isc.codfilial and  l.codloc = isc.codloc and  l.idprd = isc.idprd  
             left join pimscs.pedido_oficina po on ic.ospims = po.no_boletim and po.cd_material = isc.idprd  and instr(po.de_mensagem_int, sc.numeromov) > 0
             left join pimscs.apt_os_he h on po.instancia = h.instancia  and po.no_boletim = h.no_boletim
             left join pimscs.clasmanu clm on h.cd_clasmanu = clm.cd_clasmanu 
             left join  (select  pd.codcoligada,
                                 pd.idmov, 
                                 pd.numeromov,
                                 pd.codtmv, 
                                 pd.dataemissao,
                                 pd.status,
                                 pd.stsconcluido,
                                 pd.observacao, 
                                 r.idmovorigem,
                                 r.nseqitmmovorigem,
                                 tm.nome nometmv,
                                 ipd.nseqitmmov,
                                 nvl(ipd.quantidadeoriginal,0) quantidadeoriginal,
                                 nvl(ipd.quantidadeareceber,0) quantidadeareceber,
                                 nvl(ipd.quantidadeconcluida,0) quantidadeconcluida
                          from tmov pd, titmmovrelac r, ttmv tm, titmmov ipd
                          where pd.status <> 'C'
                            and pd.codtmv = '1.1.03'
                            and pd.codcoligada = tm.codcoligada
                            and pd.codtmv = tm.codtmv
                            and pd.codcoligada = ipd.codcoligada
                            and pd.idmov = ipd.idmov
                            
                            and ipd.codcoligada = r.codcoldestino
                            and ipd.idmov = r.idmovdestino
                            and ipd.nseqitmmov = r.nseqitmmovdestino
                            ) pd on pd.codcoligada = isc.codcoligada and isc.idmov = pd.idmovorigem   and isc.nseqitmmov = pd.nseqitmmovorigem      
                left join  (select oc.codcoligada, oc.idmov, 
                                   oc.numeromov,
                                   oc.codtmv, 
                                   oc.dataemissao,
                                   oc.status,
                                   oc.stsconcluido,
                                   f.nomefantasia,
                                   oc.valorliquidoorig,
                                   oc.dataentrega,
                                   r.idmovorigem,
                                   r.nseqitmmovorigem,
                                   tm.nome nometmv,
                                   ioc.quantidadeoriginal,
                                   ioc.precounitario,
                                   ioc.nseqitmmov    ,
                                   ioc.valordesc,
                                   nvl(ioc.quantidadeareceber,0) quantidadeareceber,
                                   nvl(ioc.quantidadeconcluida,0) quantidadeconcluida,
                                   tmarca.descmarca
                            from tmov oc, titmmovrelac r, fcfo f, ttmv tm, titmmov ioc, tmov orig, titmmov iorig, tmarca
                            where  oc.status <> 'C'
                              and oc.codtmv = '1.1.06'
                              and oc.codcoligada = tm.codcoligada
                              and oc.codtmv = tm.codtmv
                              and oc.codcoligada = ioc.codcoligada
                              and oc.idmov = ioc.idmov
                                      
                              and ioc.codcoligada = r.codcoldestino
                              and ioc.idmov = r.idmovdestino
                              and ioc.nseqitmmov = r.nseqitmmovdestino
                                      
                              and oc.codcoligada = orig.codcoligada
                              and orig.codcoligada = iorig.codcoligada
                              and orig.idmov = iorig.idmov
                              and orig.codtmv in ('1.1.03')
                                      
                              and r.codcolorigem = orig.codcoligada
                              and r.idmovorigem = orig.idmov
                              and r.nseqitmmovorigem = iorig.nseqitmmov
                                      
                                      
                              and oc.codcolcfo = f.codcoligada    
                              and oc.codcfo = f.codcfo
                              
                              and ioc.idmarca = tmarca.idmarca(+)
                              
                              ) oc on pd.codcoligada = oc.codcoligada and pd.idmov = oc.idmovorigem   and pd.nseqitmmov = oc.nseqitmmovorigem 
          left join  (select nf.codcoligada, 
                             nf.idmov, 
                             nf.numeromov,
                             nf.codtmv, 
                             nf.dataemissao,
                             nf.status,
                             f.nomefantasia,
                             nf.valorliquido,
                             nf.datamovimento,
                             r.idmovorigem, 
                             r.nseqitmmovorigem,
                             tm.nome nometmv,
                             inf.quantidadetotal,
                             inf.precounitario,
                             inf.nseqitmmov 
                      from tmov nf, titmmovrelac r, fcfo f, ttmv tm, titmmov inf
                      where nf.status <> 'C'
                        and nf.codtmv in ('1.2.02', '1.2.03', '1.2.10', '1.2.11', '1.2.13', '1.2.14', '1.2.24', '1.2.26' , '1.2.28')
                        and nf.codcoligada = tm.codcoligada
                        and nf.codtmv = tm.codtmv
                        and nf.codcoligada = inf.codcoligada
                        and nf.idmov = inf.idmov
                        
                        and inf.codcoligada = r.codcoldestino
                        and inf.idmov = r.idmovdestino
                        and inf.nseqitmmov = r.nseqitmmovdestino
                             
                        and nf.codcolcfo = f.codcoligada
                        and nf.codcfo = f.codcfo
                        ) nf on nf.codcoligada = oc.codcoligada and oc.idmov = nf.idmovorigem  and oc.nseqitmmov = nf.nseqitmmovorigem

where sc.codcoligada = :CODCOLIGADA_N
  and sc.status <> 'C'
  and sc.dataemissao between :DATAINICIAL_D and :DATAFINAL_D
  and isc.codccusto between :CC_INICIAL_S and :CC_FINAL_S
  and sc.reccreatedby like :SOLICITANTE_S  
  /* Adicionado movimento 1.1.23 conforme chamado https://app.octadesk.com/ticket/edit/33665 */
  and sc.codtmv in ('1.1.13', '1.1.40', '1.1.23')
  /* and sc.flagconclusao <> 1 Não pega os concluídos - retirado opcao em 17/11/22 ch: 27737 */
  
  union all
  
  
  select distinct sc.reccreatedby usuariocriacao_sc,
       '''' || sc.numeromov numero_sc,
       sc.observacao obs_sc,
       sc.codtmv tipo_sc,
       tm.nome nometipomov_sc,
       sc.dataemissao emissao_sc,
       case_ret_status(sc.status) status_sc,
       case when sc.stsconcluido  is null then ' '
            when sc.stsconcluido  = 'P' then 'Parc. Concluido'
            when sc.stsconcluido  = 'C' then 'Concluido'
            else 'Outro' end status_conclusao_sc,
       '''' || psc.codigoprd codigoprd_sc,
       '''' || psc.codigoauxiliar codigoaux_sc,
       '''' || psc.codtb1fat codigogrupo_sc,
       psc.nomefantasia nomeprd_sc,
       psc.codundcontrole unprd_sc,
       isc.quantidadetotal quantidade_sc,
       '''' || cc.codreduzido ccreduzido_sc,
       cc.nome ccnome_sc,     
       (select decode(nvl(a.tipoaprovacao,0),1, to_char(a.dataaprovacao, 'DD/MM/RRRR HH24:MI:SS'),'') 
        from tmovaprova a, gusuario u 
        where a.idmov = sc.idmov
         and a.codcoligada = sc.codcoligada
         and a.dataaprovacao = (select max (a.dataaprovacao) from tmovaprova a where a.idmov = sc.idmov and a.codcoligada = sc.codcoligada)
         and a.codusuario = u.codusuario) dataaprovacao_sc,
       sc.codven2 aprovador,
       
       ' ' numero_pd,
       ' ' tipo_pd,
       ' ' nometipomov_pd,
       TO_DATE('01/01/1990','dd/mm/yyyy') dataemissao_pd,
       ' ' status_pd,
       ' ' status_conclusao_pd,
       0 quantidadeoriginal,
       0 quantidadeareceber,
       0 quantidadeconcluida,
         
       oc.numeromov numero_oc,
       oc.codtmv tipo_oc,
       oc.nometmv nometipomov_oc,
       oc.dataemissao dataemissao_oc,
       case_ret_status(oc.status) status_oc,
       case when oc.stsconcluido  is null then ' '
            when oc.stsconcluido  = 'P' then 'Parc. Concluido'
            when oc.stsconcluido  = 'C' then 'Concluido'
            else oc.stsconcluido || ' Outro' end status_conclusao_oc,
       oc.nomefantasia forncecedor_oc,
       oc.dataentrega dataentrega_oc,
       oc.quantidadeoriginal quantidade_oc,
       oc.quantidadeareceber quantidadeareceber_oc,
       oc.quantidadeconcluida quantidadeconcluida_oc,
       oc.precounitario precounitario_oc,
       oc.valorliquidoorig valorliquidoorig_oc,
       oc.valordesc,
       oc.descmarca oc_marcaprod,
       
       nf.quantidadetotal quantidade_nf,
       nf.precounitario precounitario_nf,
       nf.valorliquido valorliquio_nf,       
       nf.numeromov numero_nf,
       nf.datamovimento dataentrada_nf,
       nf.valorliquido valorliquido_nf,
       nvl(l.saldofisico2,0) saldo,
       po.cd_usr_dml usuario_pims,
       po.num_docerp requisicao_erp,
       ic.ospims,
       ic.origempims,
       po.de_mensagem_int
      ,h.fg_objeto || '-' || decode(h.fg_objeto,'1','EQUIPTOS','2','AGREGADOS','3','CCUSTO') fg_objeto
      ,h.cd_equipto
      ,h.cd_agreg
      ,h.cd_ccusto
      ,clm.cd_clasmanu
      ,clm.de_clasmanu
       ,mc.tpcompra tipo_compra_sc
       , h.dt_entrada
           
from tmov sc, tmovcompl mc, ttmv tm, titmmov isc, tprd psc, gccusto cc, tprdloc l, titmmovcompl ic, pimscs.pedido_oficina po, pimscs.apt_os_he h, pimscs.clasmanu clm,

    
 (select oc.idmov, 
         oc.numeromov,
         oc.codtmv, 
         oc.dataemissao,
         oc.status,
         oc.stsconcluido,
         f.nomefantasia,
         oc.valorliquidoorig,
         oc.dataentrega,
         r.idmovorigem,
         r.nseqitmmovorigem,
         tm.nome nometmv,
         ioc.quantidadeoriginal,
         ioc.precounitario,
         ioc.nseqitmmov    ,
         ioc.valordesc,
         nvl(ioc.quantidadeareceber,0) quantidadeareceber,
         nvl(ioc.quantidadeconcluida,0) quantidadeconcluida,
         tmarca.descmarca
         
  from tmov oc, titmmovrelac r, fcfo f, ttmv tm, titmmov ioc, tmov orig, titmmov iorig, tmarca
  where oc.codcoligada = :CODCOLIGADA_N
    and oc.status <> 'C'
    and oc.codtmv = '1.1.06'
    and oc.codcoligada = tm.codcoligada
    and oc.codtmv = tm.codtmv
    and oc.codcoligada = ioc.codcoligada
    and oc.idmov = ioc.idmov
    
    and ioc.codcoligada = r.codcoldestino
    and ioc.idmov = r.idmovdestino
    and ioc.nseqitmmov = r.nseqitmmovdestino
    
    and oc.codcoligada = orig.codcoligada
    and orig.codcoligada = iorig.codcoligada
    and orig.idmov = iorig.idmov
    and orig.codtmv in ('1.1.13', '1.1.23', '1.1.40')
        
    and r.codcolorigem = orig.codcoligada
    and r.idmovorigem = orig.idmov
    and r.nseqitmmovorigem = iorig.nseqitmmov
    
    
    and oc.codcolcfo = f.codcoligada    
    and oc.codcfo = f.codcfo
    
    and ioc.idmarca = tmarca.idmarca(+)
    ) oc, 
    
 (select nf.idmov, 
         nf.numeromov,
         nf.codtmv, 
         nf.dataemissao,
         nf.status,
         f.nomefantasia,
         nf.valorliquido,
         nf.datamovimento,
         r.idmovorigem, 
         r.nseqitmmovorigem,
         tm.nome nometmv,
         inf.quantidadetotal,
         inf.precounitario,
         inf.nseqitmmov 
  from tmov nf, titmmovrelac r, fcfo f, ttmv tm, titmmov inf
  where nf.codcoligada = :CODCOLIGADA_N
    and nf.status <> 'C'
    and nf.codtmv in ('1.2.02', '1.2.03', '1.2.10', '1.2.11', '1.2.13', '1.2.14', '1.2.24', '1.2.26' , '1.2.28')
    and nf.codcoligada = tm.codcoligada
    and nf.codtmv = tm.codtmv
    and nf.codcoligada = inf.codcoligada
    and nf.idmov = inf.idmov
    
    and inf.codcoligada = r.codcoldestino
    and inf.idmov = r.idmovdestino
    and inf.nseqitmmov = r.nseqitmmovdestino
         
    and nf.codcolcfo = f.codcoligada
    and nf.codcfo = f.codcfo
    ) nf        
    
where sc.codcoligada = :CODCOLIGADA_N
  and sc.status <> 'C'
  and sc.dataemissao between :DATAINICIAL_D and :DATAFINAL_D
  and isc.codccusto between :CC_INICIAL_S and :CC_FINAL_S
  and sc.reccreatedby like :SOLICITANTE_S  
  /* Adicionado movimento 1.1.23 conforme chamado https://app.octadesk.com/ticket/edit/33665 */
  and sc.codtmv in ('1.1.13', '1.1.40', '1.1.23')
  and sc.codcoligada = mc.codcoligada(+) and sc.idmov = mc.idmov(+)
  and sc.codcoligada = tm.codcoligada
  and sc.codtmv = tm.codtmv
  and sc.codcoligada = isc.codcoligada
  and sc.idmov = isc.idmov  
  and isc.codcoligada = psc.codcoligada
  and isc.idprd = psc.idprd
  and isc.codcoligada = cc.codcoligada
  and isc.codccusto = cc.codccusto
  
  /* and sc.flagconclusao <> 1 Não pega os concluídos - retirado opcao em 17/11/22 ch: 27737 */
  
  and isc.idmov = oc.idmovorigem 
  and isc.nseqitmmov = oc.nseqitmmovorigem
  
  and oc.idmov = nf.idmovorigem(+)
  and oc.nseqitmmov = nf.nseqitmmovorigem(+) 
  
  and  l.codcoligada(+) = isc.codcoligada
  and  l.codloc(+)  = isc.codloc
  and  l.idprd(+) = isc.idprd
  and  l.codfilial(+) = isc.codfilial
  
  and  ic.codcoligada = isc.codcoligada
  and  ic.idmov = isc.idmov
  and  ic.nseqitmmov = isc.nseqitmmov  

  and ic.ospims = po.no_boletim(+)

  and po.cd_material(+) = isc.idprd
  and instr(po.de_mensagem_int(+), sc.numeromov) > 0
  
  and po.instancia = h.instancia(+)  and po.no_boletim = h.no_boletim(+)
  and h.cd_clasmanu = clm.cd_clasmanu (+)
  
  ) m
  
  order by m.numero_sc
 /* 31-10-23 - incluido o vinculo SC >> OC (contrato fornecimento) ticket 34262 */
