
// iCVSClientDemoDlg.cpp : implementation file
//

#include "stdafx.h"
#include "iCVSClientDemo.h"
#include "iCVSClientDemoDlg.h"
#include "afxdialogex.h"
#include "DlgTimeSlice.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


#define VOD_FILE	1
#define UPLOAD_FILE 0

// The CAboutDlg dialog box for the application about menu item

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// Dialog box data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CiCVSClientDemoDlg Dialog box

CiCVSClientDemoDlg::CiCVSClientDemoDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CiCVSClientDemoDlg::IDD, pParent)
	, m_szAddr(_T("103.20.120.243:9988"))
	, m_szUser(_T("admin"))
	, m_szEPID(_T("system"))
	, m_szPassword(_T("Minadadmin_"))
	, m_uiPresetPositionNo(1)
	, m_szStreamID(_T("1"))
	, m_szAlg(_T("H264"))
	, m_szResolution(_T("QCIF"))
	, m_szFrameRate(_T("20"))
	, m_szBitRate(_T("200"))
	, m_bFixAddr(TRUE)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

	m_hSession = NULL;
	m_nCurWnd = 0;

	memset(&m_PlayObjInfo, 0, sizeof(m_PlayObjInfo));

	m_nBufLen = 1024 * 1024;
	m_pFrameData = new char[m_nBufLen];
	ASSERT(m_pFrameData != NULL);
	
	m_hDownload = NULL;
	m_hUpload = NULL;

	m_pDownFile = NULL;
	m_pUploadFile = NULL;
	m_hDownloadSlice = NULL;
	m_hRecorder = NULL;

	m_nSendLen = 0;
	m_nSendFrmType = 0;
	m_bSendEndPacket = FALSE;

	m_hAudioCapEnc = NULL;
	m_hAudioDecPlay = NULL;
	m_hTalkStream = NULL;
}

void CiCVSClientDemoDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT_ADDR, m_szAddr);
	DDX_Text(pDX, IDC_EDIT_USER, m_szUser);
	DDX_Text(pDX, IDC_EDIT_EPID, m_szEPID);
	DDX_Text(pDX, IDC_EDIT_PASSWORD, m_szPassword);
	DDX_Control(pDX, IDC_TREE_RESOURCE, m_treeResource);
	DDX_Control(pDX, IDC_STATIC_WND1, m_stcWnd1);
	DDX_Control(pDX, IDC_STATIC_WND2, m_stcWnd2);
	DDX_Control(pDX, IDC_LIST_FILEINFO, m_listFileInfo);
	DDX_Text(pDX, IDC_EDIT_PRESET_POSITION_NO, m_uiPresetPositionNo);
	DDX_Text(pDX, IDC_EDIT_STREAM, m_szStreamID);
	DDX_Text(pDX, IDC_EDIT_VALG, m_szAlg);
	DDX_Text(pDX, IDC_EDIT_RESOLUTION, m_szResolution);
	DDX_Text(pDX, IDC_EDIT_FRAMERATE, m_szFrameRate);
	DDX_Text(pDX, IDC_EDIT_BITRATE, m_szBitRate);
	DDX_Control(pDX, IDC_COMBO_FILE_TYPE, m_comboFileType);
	DDX_Control(pDX, IDC_COMBO_STORAGE_TYPE, m_comboStorageType);
	DDX_Check(pDX, IDC_CHECK_FIX_ADDR, m_bFixAddr);
}

BEGIN_MESSAGE_MAP(CiCVSClientDemoDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON_LOGIN, &CiCVSClientDemoDlg::OnBnClickedButtonLogin)
	ON_BN_CLICKED(IDC_BUTTON_LOGOUT, &CiCVSClientDemoDlg::OnBnClickedButtonLogout)
	ON_WM_TIMER()
	ON_NOTIFY(NM_DBLCLK, IDC_TREE_RESOURCE, &CiCVSClientDemoDlg::OnNMDblclkTreeResource)
	ON_WM_DESTROY()
	ON_BN_CLICKED(IDC_BUTTON_START, &CiCVSClientDemoDlg::OnBnClickedButtonStart)
	ON_BN_CLICKED(IDC_BUTTON_STOP, &CiCVSClientDemoDlg::OnBnClickedButtonStop)
	ON_BN_CLICKED(IDC_BUTTON_QUERY, &CiCVSClientDemoDlg::OnBnClickedButtonQuery)
	ON_BN_CLICKED(IDC_BUTTON_DOWNLOAD, &CiCVSClientDemoDlg::OnBnClickedButtonDownload)
	ON_BN_CLICKED(IDC_BUTTON_VOD, &CiCVSClientDemoDlg::OnBnClickedButtonVod)
	ON_BN_CLICKED(IDC_BUTTON_UPLOAD, &CiCVSClientDemoDlg::OnBnClickedButtonUpload)
	ON_WM_LBUTTONUP()
	ON_BN_CLICKED(IDC_BUTTON_TEST1, &CiCVSClientDemoDlg::OnBnClickedButtonTest1)
	ON_BN_CLICKED(IDC_BUTTON_STARTTALK, &CiCVSClientDemoDlg::OnBnClickedButtonStarttalk)
	ON_BN_CLICKED(IDC_BUTTON_STOPTALK, &CiCVSClientDemoDlg::OnBnClickedButtonStoptalk)
	ON_BN_CLICKED(IDC_BUTTON_DOWNLOAD_SLICE, &CiCVSClientDemoDlg::OnBnClickedButtonDownloadSlice)
END_MESSAGE_MAP()


// CiCVSClientDemoDlg Message handler

BOOL CiCVSClientDemoDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization code here
	int nCol = 0;
	m_listFileInfo.InsertColumn(nCol++, "No", 0, 30);
	m_listFileInfo.InsertColumn(nCol++, "Name", 0, 60);
	m_listFileInfo.InsertColumn(nCol++, "Path", 0, 200);
	m_listFileInfo.InsertColumn(nCol++, "Reason", 0, 100);
	m_listFileInfo.InsertColumn(nCol++, "ID", 0, 100);
	m_listFileInfo.InsertColumn(nCol++, "Size", 0, 60);
	m_listFileInfo.InsertColumn(nCol++, "Begin", 0, 60);
	m_listFileInfo.InsertColumn(nCol++, "End", 0, 60);
	m_listFileInfo.SetExtendedStyle(LVS_EX_FULLROWSELECT);

	m_comboStorageType.InsertString(0, "Cloud storage");
	m_comboStorageType.InsertString(1, "Front storage");
	m_comboStorageType.SetCurSel(0);
	m_comboFileType.InsertString(0, "Video recording");
	m_comboFileType.InsertString(1, "Capture");
	m_comboFileType.SetCurSel(0);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CiCVSClientDemoDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CiCVSClientDemoDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // Use for drawing of device context

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center the icon in the workspace rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// drawing icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}

	CRect rtWinRect;
	if (m_nCurWnd == 0)
	{
		m_stcWnd1.GetWindowRect(rtWinRect);
	}
	else
	{
		m_stcWnd2.GetWindowRect(rtWinRect);
	}

	ScreenToClient(rtWinRect);
	rtWinRect.top -= 1;
	rtWinRect.left -= 1;
	rtWinRect.right += 1;
	rtWinRect.bottom += 1;

	CClientDC dc(this);
	CPen pen(PS_SOLID, 2, RGB(255, 0, 0));
	CPen *oldPen = dc.SelectObject(&pen);

	dc.MoveTo(rtWinRect.left, rtWinRect.top);
	dc.LineTo(rtWinRect.right, rtWinRect.top);
	dc.LineTo(rtWinRect.right, rtWinRect.bottom);
	dc.LineTo(rtWinRect.left, rtWinRect.bottom);
	dc.LineTo(rtWinRect.left, rtWinRect.top);
	dc.SelectObject(oldPen);
}

// the system calls this function to get the cursor when the user drags the minimized window

// display.
HCURSOR CiCVSClientDemoDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CiCVSClientDemoDlg::OnBnClickedButtonLogin()
{
	// TODO: Add your control notification handler code here
	UpdateData();

	if (m_hSession != NULL)
		return ;

	CString szInfo;
	int rv = 0;
	if (!m_bFixAddr)
	{
		rv = IC_Open(m_szAddr, m_szUser, m_szPassword, m_szEPID, &m_hSession);
	}
	else
	{
		rv = IC_OpenByGateway(m_szAddr, m_szUser, m_szPassword, m_szEPID, &m_hSession);
	}
	if (rv != 0)
	{
		szInfo.Format("IC_Open error, rv = %d", rv);
		AfxMessageBox(szInfo);
		return ;
	}

	int nPlatformType = 0;
	rv = IC_GetPlatformType(m_hSession, &nPlatformType);
	if (nPlatformType == 1)
	{
		IC_STR szSysName;
		rv = IC_GetSystemName(m_hSession, szSysName);
		HTREEITEM hItemRoot = m_treeResource.InsertItem(szSysName);

		int nOffset = 0;
		int nMaxForkCount = 100;

		int nDomainRoadCnt = 100;
		IC_STR *szaDomainRoadSets = new IC_STR[nDomainRoadCnt];
		IC_STR *szaDomainNameSets = new IC_STR[nDomainRoadCnt];
		rv = IC_GetSubDomain(m_hSession, szaDomainRoadSets,szaDomainNameSets, &nDomainRoadCnt);
		if (rv != 0)
		{
			szInfo.Format("IC_GetSubDomain error, rv = %d", rv);
			AfxMessageBox(szInfo);
			return ;
		}

		for (int i = 0; i < nDomainRoadCnt; i++)
		{
			HTREEITEM hItemSubDomain = m_treeResource.InsertItem(szaDomainNameSets[i], hItemRoot);
			while (true)
			{
				int nCount = nMaxForkCount;
				IC_HANDLE *haRsc = new IC_HANDLE[nCount];
				rv = IC_ForkSubDomainPUList(m_hSession, szaDomainRoadSets[i], nOffset, haRsc, &nCount);
				if (rv != 0)
				{
					delete haRsc;
					delete [] szaDomainNameSets;
					delete [] szaDomainRoadSets;
					szInfo.Format("IC_ForkSubDomainPUList error, rv = %d", rv);
					AfxMessageBox(szInfo);
					return ;
				}

				for (int j = 0; j < nCount; j++)
				{
					IC_STR szName;
					rv = IC_GetResourceName(haRsc[j], szName);
					int nOnlineFlag = 0;
					rv = IC_GetPUOnlineFlag(haRsc[j], &nOnlineFlag);

					if (nOnlineFlag == 1)
					{
						HTREEITEM hItem = m_treeResource.InsertItem(szName, hItemSubDomain);
						m_treeResource.SetItemData(hItem, (DWORD)haRsc[j]);
					}
				}
				delete haRsc;

				if (nCount == nMaxForkCount)
				{
					nOffset += nCount;
				}
				else
				{
					break;
				}
			}
		}
		delete [] szaDomainNameSets;
		delete [] szaDomainRoadSets;

		nOffset = 0;
		while (true)
		{
			int nCount = nMaxForkCount;
			IC_HANDLE *haRsc = new IC_HANDLE[nCount];
			rv = IC_ForkPUList(m_hSession, nOffset, haRsc, &nCount);
			if (rv != 0)
			{
				delete haRsc;
				szInfo.Format("IC_ForkPUList error, rv = %d", rv);
				AfxMessageBox(szInfo);
				return ;
			}

			for (int i = 0; i < nCount; i++)
			{
				IC_STR szName;
				rv = IC_GetResourceName(haRsc[i], szName);
				int nOnlineFlag = 0;
				rv = IC_GetPUOnlineFlag(haRsc[i], &nOnlineFlag);

				if (nOnlineFlag == 1)
				{
					HTREEITEM hItem = m_treeResource.InsertItem(szName, hItemRoot);
					m_treeResource.SetItemData(hItem, (DWORD)haRsc[i]);
				}
			}
			delete haRsc;

			if (nCount == nMaxForkCount)
			{
				nOffset += nCount;
			}
			else
			{
				break;
			}
		}
	}
	else
	{
		IC_HANDLE hPU = NULL;
		rv = IC_ForkOnePU(m_hSession, "", &hPU);
		if (rv != 0)
		{
			szInfo.Format("IC_ForkOnePU error, rv = %d", rv);
			AfxMessageBox(szInfo);
			return ;
		}

		IC_STR szName;
		rv = IC_GetResourceName(hPU, szName);

		IC_STR szDesc;
		rv = IC_GetResourceDescription(hPU, szDesc);

		HTREEITEM hItem = m_treeResource.InsertItem(szName);
		m_treeResource.SetItemData(hItem, (DWORD)hPU);

		m_comboStorageType.SetCurSel(1);
	}

	SetTimer(0, 500, NULL);
	SetTimer(1, 20, NULL);
}


void CiCVSClientDemoDlg::OnBnClickedButtonLogout()
{
	// TODO: Add your control notification handler code here
	KillTimer(1);
	KillTimer(0);
	m_treeResource.DeleteAllItems();

	for (int i = 0; i < MAX_PLAY_NUM; i++)
	{
		PLAY_OBJ_INFO &poi = m_PlayObjInfo[i];
		for (int j = 0; j < MAX_STREAM_NUM; j++)
		{
			IC_HANDLE &hStream = poi.hStream[j];
			if (hStream != NULL)
			{
				IC_StopStream(hStream);
				hStream = NULL;
			}
		}
		poi.hPTZ = NULL;

		if (poi.hVADR != NULL)
		{
			VARender_Close(poi.hVADR);
			poi.hVADR = NULL;
		}
	}

	if (m_hSession != NULL)
	{
		IC_Close(m_hSession);
		m_hSession = NULL;
	}
}

UINT g_uiLastTimestamp = 0;
void CiCVSClientDemoDlg::OnTimer(UINT_PTR nIDEvent)
{
	// TODO: Add your message handler code here and/or call default
	int rv = 0;
	if (nIDEvent == 0)
	{
		// Receive events
		char *szEvent = NULL;
		rv = IC_RecvEventMessage(m_hSession, &szEvent);
		if (rv == 0)
		{
			TRACE(szEvent);
			IC_ReleaseMessage(m_hSession, szEvent);
		}
		else if (rv < 0)
		{
			OnBnClickedButtonLogout();
			AfxMessageBox("disconnected from platform!");
		}
	}
	else if (nIDEvent == 1)
	{
		for (int i = 0; i < MAX_PLAY_NUM; i++)
		{
			PLAY_OBJ_INFO &poi = m_PlayObjInfo[i];
			if (poi.hVADR == NULL)
			{
				continue;
			}

			int nValidStreamNum = 0;
			for (int j = 0; j < MAX_STREAM_NUM; j++)
			{
				IC_HANDLE &hStream = poi.hStream[j];
				if (hStream == NULL)
				{
					continue;
				}
				nValidStreamNum++;

				int nLen = m_nBufLen;
				int nFrmType = 0;
				int nKeyFrmFlag = 0;
				rv = IC_ReceiveFrame(hStream, m_pFrameData, &nLen, &nFrmType, &nKeyFrmFlag);
				if (rv == 0)
				{
					UINT uiTimestamp = ((UINT*)m_pFrameData)[1];
					TRACE("[%d][%d] IC_ReceiveFrame ok, len = %d, type = %d, timestamp = %u/%u\r\n", 
						i, j, nLen, nFrmType, uiTimestamp, g_uiLastTimestamp);
					//ASSERT(uiTimestamp >= g_uiLastTimestamp);
					g_uiLastTimestamp = uiTimestamp;

					if (nFrmType == FRAME_TYPE_VIDEO)
					{
						VARender_PumpVideoFrame(poi.hVADR, m_pFrameData, nLen);
					}
					else if (nFrmType == FRAME_TYPE_AUDIO)
					{
						VARender_PumpAudioFrame(poi.hVADR, m_pFrameData, nLen);
					}
				}
				else if (rv != IC_ERROR_DC_WOULDBLOCK)
				{
					TRACE("[%d][%d] IC_ReceiveFrame error, rv = %d\r\n", i, j, rv);
					IC_StopStream(hStream);
					hStream = NULL;
				}
			}

			if (nValidStreamNum == 0)
			{
				VARender_Close(poi.hVADR);
				poi.hVADR = NULL;
			}
		}
	}
	else if (nIDEvent == 2)
	{
		while (true)
		{
			int nLen = m_nBufLen;
			int nFrmType = 0;
			int nKeyFrmFlag = 0;
			rv = IC_ReceiveFrame(m_hDownload, m_pFrameData, &nLen, &nFrmType, &nKeyFrmFlag);
			if (rv == 0)
			{
				TRACE("2 IC_ReceiveFrame ok, len = %d, type = %d\r\n", nLen, nFrmType);

				if (nFrmType == FRAME_TYPE_DATA)
				{
					fwrite(m_pFrameData + 12, sizeof(char), nLen - 12, m_pDownFile);
				}
			}
			else if (rv == IC_ERROR_DC_WOULDBLOCK)
			{
				break;
			}
			else
			{
				if (rv == IC_ERROR_END)
				{
					TRACE("Download file over.\r\n");
				}
				else
				{
					TRACE("2 IC_ReceiveFrame error, rv = %d\r\n", rv);
				}
				KillTimer(2);

				fclose(m_pDownFile);
				m_pDownFile = NULL;
				IC_StopStream(m_hDownload);
				m_hDownload = NULL;
				break;
			}
		}
	}
	else if (nIDEvent == 3)
	{
		BOOL bCloseStream = FALSE;
		while (TRUE)
		{
			if (m_nSendLen > 0)
			{
				int rv = IC_SendFrame(m_hUpload, m_pSendData, m_nSendLen, m_nSendFrmType);
				if (rv == 0)
				{
					TRACE("IC_SendFrame ok, len = %d\r\n", m_nSendLen);
					m_nSendLen = 0;
				}
				else
				{
					if (rv != IC_ERROR_DC_WOULDBLOCK)
					{
						bCloseStream = TRUE;
						TRACE("IC_SendFrame error, rv = %d", rv);
					}
					break;
				}
			}

			if (!feof(m_pUploadFile))
			{
#if UPLOAD_FILE
				((int*)m_pSendData)[0] = (int)time(NULL);
				((int*)m_pSendData)[1] = 0;
				m_pSendData[8] = 1;
				m_pSendData[9] = 0;
				m_pSendData[10] = 0;
				m_pSendData[11] = 0;
				m_nSendLen = fread(m_pSendData + 12, sizeof(char), sizeof(m_pSendData) - 12, m_pUploadFile);
				m_nSendLen += 12;
				m_nSendFrmType = FRAME_TYPE_DATA;
#else
				int nKeyFrm = 0;
				fread(&m_nSendFrmType, sizeof(int), 1, m_pUploadFile);
				fread(&nKeyFrm, sizeof(int), 1, m_pUploadFile);
				fread(&m_nSendLen, sizeof(int), 1, m_pUploadFile);
				fread(m_pSendData, sizeof(char), m_nSendLen, m_pUploadFile);
#endif
			}
			else
			{
				if (!m_bSendEndPacket)
				{
					rv = IC_SendEndPacket(m_hUpload);
					m_bSendEndPacket = TRUE;
					TRACE("IC_SendEndPacket ok, rv = %d\r\n", rv);
				}
				else
				{
					// The following logic is to ensure that the service closes the channel after receiving the data
					int nLen = m_nBufLen;
					int nKeyFrame = 0;
					int nFrameType = 0;
					rv = IC_ReceiveFrame(m_hUpload, m_pSendData, &nLen, &nFrameType, &nKeyFrame);
					if (rv < 0)
					{
						TRACE("4 IC_ReceiveFrame error, rv = %d\r\n", rv);
						bCloseStream = TRUE;
					}
				}
				break;
			}
		}
		if (bCloseStream)
		{
			m_bSendEndPacket = FALSE;

			fclose(m_pUploadFile);
			m_pUploadFile = NULL;

			IC_StopStream(m_hUpload);
			m_hUpload = NULL;

			KillTimer(3);
		}
	}
	else if (nIDEvent == 4)
	{
		bool bCloseStream = false;
		int nLen = m_nBufLen;
		int nFrmType = 0;
		int nKeyFrmFlag = 0;
		int rv = IC_ReceiveFrame(m_hTalkStream, m_pFrameData, &nLen, &nFrmType, &nKeyFrmFlag);
		if (rv == 0)
		{
			AudioDecPlay_PumpFrame(m_hAudioDecPlay, m_pFrameData, nLen);
		}
		else if (rv < 0)
		{
			TRACE("Talk IC_ReceiveFrame error, rv = %d\r\n", rv);
			bCloseStream = true;
		}

		nLen = AudioCapEnc_ReadFrame(m_hAudioCapEnc, m_pFrameData, m_nBufLen);
		if (nLen > 0)
		{
			rv = IC_SendFrame(m_hTalkStream, m_pFrameData, nLen, FRAME_TYPE_AUDIO);
			if (rv < 0)
			{
				TRACE("Talk IC_SendFrame error, rv = %d\r\n", rv);
				bCloseStream = true;
			}
			else if (rv == 0)
			{
				TRACE("Talk IC_SendFrame ok, len = %d\r\n", nLen);
			}
		}
		else if (nLen < 0)
		{
			TRACE("Talk AudioCapEnc_ReadFrame error\r\n");
			bCloseStream = true;
		}

		if (bCloseStream)
		{
			OnBnClickedButtonStoptalk();
		}
	}
	else if (nIDEvent == 5)
	{
		BOOL bCloseStream = FALSE;
		while (true)
		{
			int nLen = m_nBufLen;
			int nFrmType = 0;
			int nKeyFrmFlag = 0;
			int rv = IC_ReceiveFrame(m_hDownloadSlice, m_pFrameData, &nLen, &nFrmType, &nKeyFrmFlag);
			if (rv == 0)
			{
				if (nFrmType == FRAME_TYPE_VIDEO)
				{
					VARecorder_PumpVideoFrame(m_hRecorder, m_pFrameData, nLen);
				}
				else if (nFrmType == FRAME_TYPE_AUDIO)
				{
					VARecorder_PumpAudioFrame(m_hRecorder, m_pFrameData, nLen);
				}
			}
			else if (rv < 0)
			{
				TRACE("download record slice error, rv = %d\r\n", rv);

				bCloseStream = TRUE;
				break;
			}
			else if (rv == IC_ERROR_END)
			{
				TRACE("download record slice finished\r\n");

				bCloseStream = TRUE;
				break;
			}
			else if (rv == IC_ERROR_DC_WOULDBLOCK)
			{
				break;
			}
		}
		if (bCloseStream)
		{
			IC_StopStream(m_hDownloadSlice);
			m_hDownloadSlice = NULL;
			VARecorder_Close(m_hRecorder);
			m_hRecorder = NULL;

			KillTimer(5);
		}
	}
	CDialogEx::OnTimer(nIDEvent);
}


void CiCVSClientDemoDlg::OnNMDblclkTreeResource(NMHDR *pNMHDR, LRESULT *pResult)
{
	// TODO: Add your control notification handler code here
	*pResult = 0;
	UpdateData();

	int rv = 0;
	CString szInfo;
	HTREEITEM hItem = m_treeResource.GetSelectedItem();
	if (hItem == NULL)
	{
		return ;
	}

	DWORD dwData = m_treeResource.GetItemData(hItem);
	if (dwData == NULL)
	{
		return ;
	}

	IC_HANDLE hRsc = (IC_HANDLE)dwData;
	IC_STR szType;
	rv = IC_GetResourceType(hRsc, szType);

	if (strcmp(szType, RESOURCE_TYPE_ST) == 0)
	{
		IC_HANDLE haRes[500];
		int nCount = 500;
		rv = IC_ForkPUResource(hRsc, haRes, &nCount);
		if (rv == 0)
		{
			for (int i = 0; i < nCount; i++)
			{
				IC_STR szName;
				rv = IC_GetResourceName(haRes[i], szName);
				HTREEITEM hCurItem = m_treeResource.InsertItem(szName, hItem);
				m_treeResource.SetItemData(hCurItem, (DWORD)haRes[i]);
			}
		}
		else
		{
			szInfo.Format("IC_ForkPUResource error, rv = %d", rv);
			AfxMessageBox(szInfo);
		}
	}
	else if (strcmp(szType, RESOURCE_TYPE_IV) == 0)
	{
		PLAY_OBJ_INFO &poi = m_PlayObjInfo[m_nCurWnd];
		for (int j = 0; j < MAX_STREAM_NUM; j++)
		{
			IC_HANDLE &hStream = poi.hStream[j];
			if (hStream != NULL)
			{
				IC_StopStream(hStream);
				hStream = NULL;
			}
		}
		poi.hPTZ = NULL;
		poi.hOA = NULL;

		if (poi.hVADR != NULL)
		{
			VARender_Close(poi.hVADR);
			poi.hVADR = NULL;
		}

		// Get window
		HWND hWnd = m_nCurWnd == 0 ? m_stcWnd1.m_hWnd : m_stcWnd2.m_hWnd;

		// Obtaining flow type
		if (m_szStreamID == "TC")
		{
			int nBitRate = strtol(m_szBitRate, NULL, 10);
			int nFrameRate = strtol(m_szFrameRate, NULL, 10);
			rv = IC_StartTranscodeStream(hRsc, m_szAlg, m_szResolution, nBitRate, nFrameRate, &poi.hStream[0]);
		}
		else
		{
			// Play video
			int nStreamID = strtol(m_szStreamID, NULL, 10);
			rv = IC_StartStream(hRsc, nStreamID, &poi.hStream[0]);
		}

		if (rv == 0)
		{
			rv = VARender_Open(&poi.hVADR);
			ASSERT(rv == 0);
			rv = VARender_SetWindow(poi.hVADR, hWnd);
			ASSERT(rv == 0);
			VARender_StartVideo(poi.hVADR);

			int nResIndex = 0;
			rv = IC_GetResourceIndex(hRsc, &nResIndex);
			ASSERT(rv == 0);

			IC_HANDLE hPU = NULL;
			rv = IC_GetPUHandle(hRsc, &hPU);
			ASSERT(rv == 0);

			rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_IA, nResIndex, &hRsc);
			if (rv == 0)
			{
				rv = IC_StartStream(hRsc, 0, &poi.hStream[1]);
				if (rv == 0)
				{
					VARender_StartAudio(poi.hVADR);
				}
				else
				{
					szInfo.Format("IC_StartStream audio error, rv = %d", rv);
				}
			}

			rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_PTZ, nResIndex, &hRsc);
			if (rv == 0)
			{
				poi.hPTZ = hRsc;
			}

			rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_OA, 0, &hRsc);
			if (rv == 0)
			{
				poi.hOA = hRsc;
			}
		}
		else
		{
			szInfo.Format("IC_StartStream error, rv = %d", rv);
			AfxMessageBox(szInfo);
		}
	}
}

void CiCVSClientDemoDlg::OnDestroy()
{
	CDialogEx::OnDestroy();

	// TODO: Add your message handler code here
	OnBnClickedButtonLogout();
	delete m_pFrameData;
}

void CiCVSClientDemoDlg::OnBnClickedButtonStart()
{
	// TODO: Add your control notification handler code here
	int rv = 0;
	int nDuration = 10;
	int nStorageType = IsRecordType() ? 0 : 1;
	int nReserveDay = 3;
	int nFileLength = 10;
	int nStreamID = 0;
	int nSnapshotNumber = 10;
	int nSnapshotInterval = 20;
	const char *pszReason = "Manual";

	HTREEITEM hItem = m_treeResource.GetSelectedItem();
	IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);

	IC_STR szPUID;
	rv = IC_GetResourcePUID(hRes, szPUID);
	ASSERT(rv == 0);

	int nIndex = 0;
	rv = IC_GetResourceIndex(hRes, &nIndex);
	ASSERT(rv == 0);

	if (IsCloudStorage())
	{
		IC_STR szID;
		//rv = IC_CSSManualStart(m_hSession, pszReason, nDuration, nStorageType, 
		//	nReserveDay, nFileLength, szPUID, nIndex, nStreamID, szID);
		rv = IC_CSSManualStart(m_hSession, pszReason, nDuration, nStorageType, nReserveDay, nFileLength, szPUID, nIndex, nStreamID, 0, szID);


		ASSERT(rv == 0);
		m_szManualStorageID = szID;
	}
	else 
	{
		IC_HANDLE hPU = NULL;
		rv = IC_GetPUHandle(hRes, &hPU);
		ASSERT(rv == 0);

		IC_HANDLE hSG = NULL;
		rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_SG, 0, &hSG);
		ASSERT(rv == 0);
		if (hSG == NULL)
		{
			AfxMessageBox("the pu has no storage resource");
			return ;
		}
		if (IsRecordType())
		{
			rv = IC_StartRecord(hSG, nIndex, nDuration, pszReason);
		}
		else
		{
			rv = IC_StartSnapshot(hSG, nIndex, nSnapshotNumber, nSnapshotInterval, pszReason);
		}
		ASSERT(rv == 0);
	}
}


void CiCVSClientDemoDlg::OnBnClickedButtonStop()
{
	// TODO: Add your control notification handler code here
	int rv = 0;

	if (IsCloudStorage())
	{
		rv = IC_CSSManualStop(m_hSession, m_szManualStorageID);
	}
	else
	{
		HTREEITEM hItem = m_treeResource.GetSelectedItem();
		IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);

		IC_STR szPUID;
		rv = IC_GetResourcePUID(hRes, szPUID);
		ASSERT(rv == 0);

		int nIndex = 0;
		rv = IC_GetResourceIndex(hRes, &nIndex);
		ASSERT(rv == 0);

		IC_HANDLE hPU = NULL;
		rv = IC_GetPUHandle(hRes, &hPU);
		ASSERT(rv == 0);

		IC_HANDLE hSG = NULL;
		rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_SG, 0, &hSG);
		ASSERT(rv == 0);
		if (hSG == NULL)
		{
			AfxMessageBox("the pu has no storage resource");
			return ;
		}

		rv = IC_StopRecord(hSG, nIndex);
	}
	ASSERT(rv == 0);
}


void CiCVSClientDemoDlg::OnBnClickedButtonQuery()
{
	// TODO: Add your control notification handler code here
	m_listFileInfo.DeleteAllItems();
	int rv = 0;

	int nEndTime = (int)time(NULL);
	int nBeginTime = nEndTime - 5 * 24 * 60 * 60;

	HTREEITEM hItem = m_treeResource.GetSelectedItem();
	if (hItem == NULL)
	{
		AfxMessageBox("Please select a camera");
		return ;
	}
	IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);

	IC_STR szPUID;
	rv = IC_GetResourcePUID(hRes, szPUID);
	ASSERT(rv == 0);

	IC_HANDLE haRes[1];
	haRes[0] = hRes;

	int nCount = 200;
	IC_FILE_INFO *pFileInfo = new IC_FILE_INFO[nCount];
	memset(pFileInfo, 0, sizeof(IC_FILE_INFO) * nCount);

	int nFileType = IsRecordType() ? 0 : 1;
	if (IsCloudStorage())
	{
		rv = IC_CSSQueryFile(m_hSession, nBeginTime, nEndTime, nFileType, NULL, 0, haRes, 1, 0, pFileInfo, &nCount);
		//rv = IC_CSSQueryUploadFile(m_hSession, nBeginTime, nEndTime, "AND", pReason, 2, 0, pFileInfo, &nCount);
	}
	else
	{
		int nIndex = 0;
		rv = IC_GetResourceIndex(hRes, &nIndex);
		ASSERT(rv == 0);

		IC_HANDLE hPU = NULL;
		rv = IC_GetPUHandle(hRes, &hPU);
		ASSERT(rv == 0);

		IC_HANDLE hSG = NULL;
		rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_SG, 0, &hSG);
		ASSERT(rv == 0);
		if (hSG == NULL)
		{
			AfxMessageBox("the pu has no storage resource");
			return ;
		}

		rv = IC_QueryFile(hSG, nIndex, nBeginTime, nEndTime, nFileType, 0, pFileInfo, &nCount);
	}
	ASSERT(rv == 0);

	for (int i = 0; i < nCount; i++)
	{
		CString szText;
		szText.Format("%d", i);
		m_listFileInfo.InsertItem(i, szText);
		m_listFileInfo.SetItemText(i, 1, pFileInfo[i].szName);
		m_listFileInfo.SetItemText(i, 2, pFileInfo[i].szPath);
		m_listFileInfo.SetItemText(i, 3, pFileInfo[i].szReasons);
		m_listFileInfo.SetItemText(i, 4, IsCloudStorage() ? pFileInfo[i].szID : szPUID);
		szText.Format("%u", pFileInfo[i].nSize);
		m_listFileInfo.SetItemText(i, 5, szText);

		time_t tBegin = pFileInfo[i].un.record.nBeginTime;
		strftime(szText.GetBuffer(256), 256, "%Y-%m-%d_%H-%M-%S", localtime(&tBegin));
		szText.ReleaseBuffer();
		m_listFileInfo.SetItemText(i, 6, szText);

		time_t tEnd = pFileInfo[i].un.record.nEndTime;
		strftime(szText.GetBuffer(256), 256, "%Y-%m-%d_%H-%M-%S", localtime(&tEnd));
		szText.ReleaseBuffer();
		m_listFileInfo.SetItemText(i, 7, szText);
	}
	delete pFileInfo;
}


void CiCVSClientDemoDlg::OnBnClickedButtonDownload()
{
	// TODO: Add your control notification handler code here
	POSITION pos = m_listFileInfo.GetFirstSelectedItemPosition();
	if (pos == NULL)
	{
		AfxMessageBox("Please select a file!");
		return ;
	}

	if (m_hDownload != NULL)
	{
		AfxMessageBox("A download task is running, plz wait!");
		return ;
	}

	int nIndex = m_listFileInfo.GetNextSelectedItem(pos);
	CString szPathname = m_listFileInfo.GetItemText(nIndex, 2);
	CString szFilename = m_listFileInfo.GetItemText(nIndex, 1);
	szPathname += szFilename;
	CString szID = m_listFileInfo.GetItemText(nIndex, 4);
	int rv = 0;
	if (IsCloudStorage())
	{
		rv = IC_CSSDownloadFile(m_hSession, szID, szPathname, 0, -1, &m_hDownload);
	}
	else
	{
		IC_HANDLE hPU = NULL;
		rv = IC_ForkOnePU(m_hSession, szID, &hPU);
		ASSERT(rv == 0);

		IC_HANDLE hSG = NULL;
		rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_SG, 0, &hSG);
		ASSERT(rv == 0);

		rv = IC_DownloadFile(hSG, szPathname, 0, -1, &m_hDownload);
	}
	if (rv != 0)
	{
		CString szInfo;
		szInfo.Format("download file error, rv = %d", rv);
		AfxMessageBox(szInfo);
		return ;
	}

	fopen_s(&m_pDownFile, szFilename, "wb");
	SetTimer(2, 10, NULL);
}


void CiCVSClientDemoDlg::OnBnClickedButtonVod()
{
	// TODO: Add your control notification handler code here
	PLAY_OBJ_INFO &poi = m_PlayObjInfo[m_nCurWnd];
	for (int j = 0; j < MAX_STREAM_NUM; j++)
	{
		IC_HANDLE &hStream = poi.hStream[j];
		if (hStream != NULL)
		{
			IC_StopStream(hStream);
			hStream = NULL;
		}
	}
	poi.hPTZ = NULL;

	IC_HANDLE hStream = NULL;
	IC_STR szVodID;
#if VOD_FILE
	POSITION pos = m_listFileInfo.GetFirstSelectedItemPosition();
	if (pos == NULL)
	{
		AfxMessageBox("Please select a file!");
		return ;
	}

	int nIndex = m_listFileInfo.GetNextSelectedItem(pos);
	CString szPathname = m_listFileInfo.GetItemText(nIndex, 2);
	szPathname += m_listFileInfo.GetItemText(nIndex, 1);
	CString szID = m_listFileInfo.GetItemText(nIndex, 4);

	int rv = 0;
	if (IsCloudStorage())
	{
		rv = IC_CSSVODFile(m_hSession, szID, szPathname, 1, 20, 10, -1, szVodID, &hStream);
	}
	else
	{
		HTREEITEM hItem = m_treeResource.GetSelectedItem();
		IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);
		rv = IC_VODFile(hRes, szPathname, 1, 0, szVodID, &hStream);
	}
	ASSERT(rv == 0);
#else
	HTREEITEM hItem = m_treeResource.GetSelectedItem();
	IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);

	int nEndTime = (int)time(NULL) - 600;
	int nBeginTime = nEndTime - 200;
	int rv = IC_CSSVODTime(m_hSession, hRes, nBeginTime, nEndTime, 0, szVodID, &hStream);
	if (rv != 0)
	{
		AfxMessageBox("vod file error");
		return ;
	}
#endif
	m_szVodID = szVodID;

	if (poi.hVADR != NULL)
	{
		VARender_Close(poi.hVADR);
		poi.hVADR = NULL;
	}
	poi.hStream[0] = hStream;
	rv = VARender_Open(&poi.hVADR);
	ASSERT(rv == 0);
	HWND hWnd = m_nCurWnd == 0 ? m_stcWnd1.m_hWnd : m_stcWnd2.m_hWnd;
	rv = VARender_SetWindow(poi.hVADR, hWnd);
	ASSERT(rv == 0);
	VARender_StartVideo(poi.hVADR);
	VARender_StartAudio(poi.hVADR);
}


void CiCVSClientDemoDlg::OnBnClickedButtonUpload()
{
	// TODO: Add your control notification handler code here
	if (!IsCloudStorage())
	{
		AfxMessageBox("not support");
		return ;
	}

	CFileDialog fileDlg(TRUE);
	if (fileDlg.DoModal() != IDOK)
	{
		return ;
	}
	
	CString szFile = fileDlg.GetFileName();
	CString szPath = fileDlg.GetPathName();
	if (fopen_s(&m_pUploadFile, szPath, "rb") != 0)
	{
		AfxMessageBox("open file error!");
		return ;
	}

#if UPLOAD_FILE
	int nTime = (int)time(NULL);
	IC_STR szaReason[2];
	strcpy_s(szaReason[0], "12345");
	strcpy_s(szaReason[1], "111");
	IC_STR szID = { 0 };
	int nLength = 0;
	int rv = IC_CSSUploadFile(m_hSession, szFile, nTime, 1, szaReason, 1, szID, &nLength, &m_hUpload);
#else
	int rv = IC_CSSUploadRecord(m_hSession, "201115202669740426", 0, 0, "Upload Record", 3, 5, &m_hUpload);
#endif
	ASSERT(rv == 0);

	SetTimer(3, 30, NULL);
}


void CiCVSClientDemoDlg::OnLButtonUp(UINT nFlags, CPoint point)
{
	// TODO: Add your message handler code here and/or call default
	CRect rcWnd1;
	m_stcWnd1.GetWindowRect(rcWnd1);
	ScreenToClient(rcWnd1);

	CRect rcWnd2;
	m_stcWnd2.GetWindowRect(rcWnd2);
	ScreenToClient(rcWnd2);

	if (PtInRect(rcWnd1, point))
	{
		if (m_nCurWnd != 0)
		{
			m_nCurWnd = 0;
			RedrawWindow();
		}
	}
	else if (PtInRect(rcWnd2, point))
	{
		if (m_nCurWnd != 1)
		{
			m_nCurWnd = 1;
			RedrawWindow();
		}
	}

	CDialogEx::OnLButtonUp(nFlags, point);
}


BOOL CiCVSClientDemoDlg::PreTranslateMessage(MSG* pMsg)
{
	// TODO: Add your specialized code here and/or call the base class
	PLAY_OBJ_INFO &poi = m_PlayObjInfo[m_nCurWnd];
	if (poi.hPTZ != NULL)
	{
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_TURN_UP)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_StartTurnUp(poi.hPTZ, 0);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopTurn(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_TURN_DOWN)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_StartTurnDown(poi.hPTZ, 0);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopTurn(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_TURN_LEFT)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_StartTurnLeft(poi.hPTZ, 0);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopTurn(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_TURN_RIGHT)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_StartTurnRight(poi.hPTZ, 0);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopTurn(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_FOCUS_FAR)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_MakeFocusFar(poi.hPTZ);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopFocusMove(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_FOCUS_NEAR)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_MakeFocusNear(poi.hPTZ);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopFocusMove(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_ZOOM_IN)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_ZoomInPicture(poi.hPTZ);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopPictureZoom(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_ZOOM_OUT)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONDOWN)
			{
				IC_ZoomOutPicture(poi.hPTZ);
			}
			else if (pMsg->message == WM_LBUTTONUP)
			{
				IC_StopPictureZoom(poi.hPTZ);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_GOTO_PRESET_POSITION)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONUP)
			{
				IC_MoveToPresetPos(poi.hPTZ, m_uiPresetPositionNo);
			}
		}
		if (pMsg->hwnd == GetDlgItem(IDC_BUTTON_SET_PRESET_POSITION)->m_hWnd)
		{
			if (pMsg->message == WM_LBUTTONUP)
			{
				CString szName;
				szName.Format("%u", m_uiPresetPositionNo);
				IC_SetPresetPos(poi.hPTZ, m_uiPresetPositionNo, szName);
			}
		}
	}

	return CDialogEx::PreTranslateMessage(pMsg);
}


void CiCVSClientDemoDlg::OnBnClickedButtonTest1()
{
	// TODO: Add your control notification handler code here
	//UINT uiTime = (UINT)time(NULL);
	//char szCUID[64] = { 0 };
	//rv = IC_GetSessionID(m_hSession, szCUID);
	//sprintf_s(str, "<?xml version=\"1.0\" encoding=\"utf-8\"?><M Type=\"CusReq\"><C Type=\"C\" OptID=\"C_CAS_SendCustomEvent\"><Dst Type=\"8\" ID=\"\"></Dst><E ID=\"E_CUSTOM_TEST\" Time=\"%u\" Ignore=\"0\" Level=\"Notify\"><Src Type=\"203\" ID=\"%s\"><Res Type=\"ST\" Idx=\"0\" Name=\"\" Desc=\"\" /></Src><Desc /></E></C></M>",
	//	uiTime, szCUID);
	//rv = IC_TransCusMessage(m_hSession, str, &szRsp);
	//ASSERT(rv == 0);
	//IC_ReleaseMessage(m_hSession, szRsp);

	//HTREEITEM hItem = m_treeResource.GetSelectedItem();
	//IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);

	//IC_STR szDecoder;
	//int rv = IC_GetAudioDecoder(hRes, szDecoder);
	//ASSERT(rv == 0);
	//IC_STR szProducerID;
	//rv = IC_GetDecoderProducerID(hRes, szProducerID);
	//ASSERT(rv == 0);

	//int nTransID = 0;
	//char szReq[1024] = { 0 };
	//sprintf_s(szReq, "<?xml version=\"1.0\" encoding=\"utf-8\"?><M Type=\"ComReq\"><C Type=\"C\" Prio=\"1\" EPID=\"system\"><Res Type=\"ST\" Idx=\"0\" OptID=\"C_CSS_QueryStorageFiles\"><Param Offset=\"0\" Count=\"200\" Begin=\"1427904000\" End=\"1428076799\" Type=\"0\" /></Res></C><OSets><Res OType=\"201\" OID=\"201115201224738191\" Type=\"IV\" Idx=\"0\" /></OSets></M>");
	//int rv = IC_SendComReqWithDomainRoad(m_hSession, 14, "AA", szReq, &nTransID);
	//ASSERT(rv == 0);
	//while (true)
	//{
	//	char *szRsp = NULL;
	//	rv = IC_RecvComRsp(m_hSession, nTransID, &szRsp);
	//	if (rv == 0)
	//	{
	//		TRACE("IC_RecvComRsp ok, rsp = %s\r\n", szRsp);
	//		IC_ReleaseMessage(m_hSession, szRsp);
	//		break;
	//	}
	//	else if (rv < 0)
	//	{
	//		ASSERT(0);
	//	}
	//	else
	//	{
	//		Sleep(10);
	//	}
	//}

	////const char *pszOptID = "C_ES_SendOnlineSMS";
	//const char *pszOptID = "C_ES_SendOfflineSMS";
	//const char *pszPUID = "201115200370147727";
	////const char *pszPUID = "201115200184550287";
	//CString szReq;
	//szReq.Format("<?xml version=\"1.0\" encoding=\"utf-8\"?><M Type=\"ComReq\"><C Type=\"C\" Prio=\"1\" EPID=\"system\"><Res Type=\"ST\" Idx=\"0\" OptID=\"%s\"><Param /></Res></C><OSets><Res OType=\"201\" OID=\"%s\" Type=\"ST\" Idx=\"0\" /></OSets></M>", pszOptID, pszPUID);
	//char *szRsp = NULL;
	//int rv = IC_TransMessage(m_hSession, 12, "", szReq, &szRsp);
	//if (rv == 0)
	//{
	//	TRACE("IC_TransMessage ok, rsp = %s\r\n", szRsp);
	//	IC_ReleaseMessage(m_hSession, szRsp);
	//}

	//CString szReq;
	//szReq.Format("<?xml version=\"1.0\" encoding=\"utf-8\"?><M Type=\"ComReq\"><C Type=\"C\" Prio=\"1\" EPID=\"system\"><Res Type=\"ST\" Idx=\"0\" OptID=\"%s\"><Param Title=\"test\" Text=\"test\" Attachment=\"\" Extension=\"\"><Email Addr=\"xmwang3@qq.com\" /></Param></Res></C></M>", "C_ES_SendMail");
	//char *szRsp = NULL;
	//int rv = IC_TransMessage(m_hSession, 12, "", szReq, &szRsp);
	//if (rv == 0)
	//{
	//	TRACE("IC_TransMessage ok, rsp = %s\r\n", szRsp);
	//	IC_ReleaseMessage(m_hSession, szRsp);
	//}

	//static bool bPause = false;
	//if (!bPause)
	//{
	//	IC_CSSVODPause(m_hSession, m_szVodID);
	//	bPause = true;
	//}
	//else
	//{
	//	IC_CSSVODResume(m_hSession, m_szVodID);
	//	bPause = false;
	//}
	
	//static int nPos = 10;
	//srand(nPos);
	//nPos = rand() % 200;
	//IC_CSSVODChangePosition(m_hSession, m_szVodID, nPos);
	//TRACE("IC_CSSVODChangePosition nPos = %d\r\n", nPos);
	//return ;

	//static bool bSubscribe = false;
	//CString szReq;
	//if (!bSubscribe)
	//{
	//	szReq.Format("<?xml version=\"1.0\" encoding=\"utf-8\"?><M Type=\"ComReq\"><C Type=\"C\" Prio=\"1\" EPID=\"system\"><Res Type=\"ST\" Idx=\"0\" OptID=\"C_GS_SubscribeGPSData\"><Param></Param></Res></C><OSets><Res OType=\"201\" OID=\"201923456789011999\" Type=\"GPS\" Idx=\"0\"></Res></OSets></M>");
	//	bSubscribe = true;
	//}
	//else
	//{
	//	szReq.Format("<?xml version=\"1.0\" encoding=\"utf-8\"?><M Type=\"ComReq\"><C Type=\"C\" Prio=\"1\" EPID=\"system\"><Res Type=\"ST\" Idx=\"0\" OptID=\"C_GS_UnsubscribeGPSData\"><Param></Param></Res></C><OSets><Res OType=\"201\" OID=\"201923456789011999\" Type=\"GPS\" Idx=\"0\"></Res></OSets></M>");
	//	bSubscribe = false;
	//}
	//char *szRsp = NULL;
	//int rv = IC_TransMessage(m_hSession, 33, "", szReq, &szRsp);
	//if (rv == 0)
	//{
	//	TRACE("IC_TransMessage ok, rsp = %s\r\n", szRsp);
	//	IC_ReleaseMessage(m_hSession, szRsp);
	//}

	PLAY_OBJ_INFO &poi = m_PlayObjInfo[m_nCurWnd];
	for (int j = 0; j < MAX_STREAM_NUM; j++)
	{
		IC_HANDLE &hStream = poi.hStream[j];
		if (hStream != NULL)
		{
			IC_StopStream(hStream);
			hStream = NULL;
		}
	}
	poi.hPTZ = NULL;

	if (poi.hVADR != NULL)
	{
		VARender_Close(poi.hVADR);
		poi.hVADR = NULL;
	}

	RedrawWindow();
}


void CiCVSClientDemoDlg::OnBnClickedButtonStarttalk()
{
	// TODO: Add your control notification handler code here
	OnBnClickedButtonStoptalk();

	PLAY_OBJ_INFO &poi = m_PlayObjInfo[m_nCurWnd];
	if (poi.hOA == NULL)
	{
		return ;
	}

	int rv = IC_StartTalk(poi.hOA, &m_hTalkStream);
	ASSERT(rv == 0);

	rv = AudioCapEnc_Open(1, "G711U", 0, &m_hAudioCapEnc);
	ASSERT(rv == 0);

	rv = AudioDecPlay_Open(&m_hAudioDecPlay);
	ASSERT(rv == 0);

	SetTimer(4, 20, NULL);
}


void CiCVSClientDemoDlg::OnBnClickedButtonStoptalk()
{
	// TODO: Add your control notification handler code here
	KillTimer(4);

	if (m_hAudioCapEnc != NULL)
	{
		AudioCapEnc_Close(m_hAudioCapEnc);
		m_hAudioCapEnc = NULL;
	}

	if (m_hAudioDecPlay != NULL)
	{
		AudioDecPlay_Close(m_hAudioDecPlay);
		m_hAudioDecPlay = NULL;
	}

	if (m_hTalkStream != NULL)
	{
		IC_StopStream(m_hTalkStream);
		m_hTalkStream = NULL;
	}
}


void CiCVSClientDemoDlg::OnBnClickedButtonDownloadSlice()
{
	// TODO: Add your control notification handler code here
	HTREEITEM hItem = m_treeResource.GetSelectedItem();
	if (hItem == NULL)
	{
		AfxMessageBox("Please select a camera");
		return ;
	}
	IC_HANDLE hRes = (IC_HANDLE)m_treeResource.GetItemData(hItem);
	IC_HANDLE haRes[1] = { hRes };

	CDlgTimeSlice dlgTimeSlice;
	if (dlgTimeSlice.DoModal() != IDOK)
	{
		return ;
	}

	if (dlgTimeSlice.m_tBegin >= dlgTimeSlice.m_tEnd)
	{
		return ;
	}
	int nBeginTime = (int)dlgTimeSlice.m_tBegin.GetTime();
	int nEndTime = (int)dlgTimeSlice.m_tEnd.GetTime();

	int rv = 0;
	IC_STR szVodID;
	int nFileType = IsRecordType() ? 0 : 1;
	if (IsCloudStorage())
	{
		rv = IC_CSSVODTime(m_hSession, hRes, nBeginTime, nEndTime, 32, szVodID, &m_hDownloadSlice);
	}
	else
	{
		int nIndex = 0;
		rv = IC_GetResourceIndex(hRes, &nIndex);
		ASSERT(rv == 0);

		IC_HANDLE hPU = NULL;
		rv = IC_GetPUHandle(hRes, &hPU);
		ASSERT(rv == 0);

		IC_HANDLE hSG = NULL;
		rv = IC_GetResourceHandle(hPU, RESOURCE_TYPE_SG, 0, &hSG);
		ASSERT(rv == 0);
		if (hSG == NULL)
		{
			AfxMessageBox("the pu has no storage resource");
			return ;
		}

		rv = IC_VODTime(hSG, nIndex, nBeginTime, nEndTime, szVodID, &m_hDownloadSlice);
	}
	ASSERT(rv == 0);

	rv = VARecorder_Open("test.avi", &m_hRecorder);
	ASSERT(rv == 0);
	SetTimer(5, 10, NULL);
}
